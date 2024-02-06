class ReturnTransferOrder < ApplicationRecord
  audited
  belongs_to :warehouse
  belongs_to :staff, optional: true
  has_many :boxes, dependent: :destroy, as: :boxable, class_name: 'Box'
  has_many :box_line_items, through: :boxes
  has_many :line_items, dependent: :destroy, as: :itemable
  has_many :failed_qcs, as: :failable
  has_many :stock_changes, as: :stock_changeable

  attr_accessor :changed_by

  # Scopes are written here:
  default_scope { order(created_at: :desc) }
  default_scope { where(is_deleted: false) }

  # Model callbacks are written here
  after_update :update_dwh_variant_quantity, if: :saved_change_to_order_status?
  after_update :generate_history_for_status_changes, if: :saved_change_to_order_status?

  enum order_status:
         {
           order_placed: 0,
           order_confirmed: 1,
           ready_to_ship: 2,
           in_transit: 3,
           received_to_cwh: 4,
           completed: 5,
           reconcilation_pending: 6,
         }

  def create_line_item(variant, quantity)
    line_items.create(
      variant: variant,
      quantity: quantity,
      price: variant.price_distribution.to_d,
    )
  end

  def self.getOrderStatus(status)
    self.order_statuses[status]
  end

  def transfer_order_stock_update(items, warehouse)
    updated_quantity_count = 0
    ActiveRecord::Base.transaction do
      items.each do |item|
        send_quantity = item[:quantity]
        sku = item[:sku]
        line_item = line_items.find_by(id: item[:line_item_id])
        warehouse_variant = line_item.variant.warehouse_variants.find_by(warehouse: warehouse)
        wv_location = warehouse_variant.warehouse_variants_locations.find_by(location_id: item[:location_id])
        unless send_quantity <= warehouse_variant.available_quantity && send_quantity <= wv_location.quantity
          fail StandardError, "Quantity not available for sku: #{line_item.variant.sku}."
        end

        wv_location.update!(quantity: (wv_location.quantity - send_quantity))
        line_item.update!(qr_code: sku, send_quantity: send_quantity)
        updated_quantity_count += 1
      end
    end
    items.count == updated_quantity_count
  end

  def boxable_check(list, size)
    items = line_items_check(list, size)
    return { boxable: false, message: 'Requested line items not found' } if items[:boxable] == false

    box = existing_box_check(items[:items].ids)
    return { boxable: false, message: 'Requested items are already in box!' } if box[:boxable] == false

    { items: items[:items], boxable: true }
  end

  def existing_box_check(line_items_id)
    box_items = BoxLineItem.where(line_item_id: line_items_id)
    return { boxable: true } if box_items.blank?

    { boxable: false, box_item: line_items }
  end

  def line_items_check(list, size)
    line_items = self.line_items.where(id: list.map(&:to_i))
    return { boxable: false } if line_items.count != size

    { items: line_items, boxable: true }
  end

  def create_box(line_items, user_id)
    box = boxes.create!
    box.update!(created_by_id: user_id)
    all_items = box_items(line_items)
    box.box_line_items.create!(all_items)
    box
  end

  def box_items(line_items)
    all_items = []
    line_items.each do |item|
      box_item = { line_item_id: item.id }
      all_items.push(box_item)
    end
    all_items
  end

  def all_boxed?
    return false unless line_items.count == box_line_items.count

    boxes = box_line_items.pluck(:box_id).uniq
    packed = Box.packed.where(id: boxes)
    return false unless packed.size == boxes.size

    true
  end

  def update_dwh_variant_quantity
    line_items.each do |item|
      warehouse_variant = item.variant.warehouse_variants.find_by(warehouse: warehouse)

      case order_status
      when 'ready_to_ship'
        if (warehouse_variant.available_quantity - item.send_quantity).negative?
          Rails.logger.error "\nAvailable_quantity is being negative for sku = #{item.variant.sku} and warehouse_variant_id: #{warehouse_variant.id}. Action: Pack and Line_Item_id: #{item.id}\n"
        end
        warehouse_variant.update!(available_quantity: warehouse_variant.available_quantity - item.send_quantity,
                                  packed_quantity: warehouse_variant.packed_quantity + item.send_quantity)
        warehouse_variant.save_stock_change('rto_pack', item.send_quantity, item.itemable, 'available_quantity_change', 'packed_quantity_change')
      when 'in_transit'
        if (warehouse_variant.packed_quantity - item.send_quantity).negative?
          Rails.logger.error "\nPacked_quantity is being negative for sku = #{item.variant.sku} and warehouse_variant_id: #{warehouse_variant.id}. Action: Dispatch and Line_Item_id: #{item.id}\n"
        end
        warehouse_variant.update!(packed_quantity: warehouse_variant.packed_quantity - item.send_quantity,
                                  in_transit_quantity: warehouse_variant.in_transit_quantity + item.send_quantity)
        warehouse_variant.save_stock_change('rto_in_transit', item.send_quantity, item.itemable, 'packed_quantity_change', 'in_transit_quantity_change')
      when 'received_to_cwh'
        if (warehouse_variant.in_transit_quantity - item.send_quantity).negative?
          Rails.logger.error "\nIn_transit_quantity is being negative for sku = #{item.variant.sku} and warehouse_variant_id: #{warehouse_variant.id}. Action: Receive and Line_Item_id: #{item.id}\n"
        end
        warehouse_variant.update!(in_transit_quantity: warehouse_variant.in_transit_quantity - item.send_quantity)
        warehouse_variant.save_stock_change('rto_received_to_cwh', item.send_quantity, item.itemable, 'in_transit_quantity_change', nil)
      end
    end
  end

  def update_reconcilation_status(changed_by)
    return unless reconcilation_pending?

    self.changed_by = changed_by
    completed! unless failed_qcs.where(is_settled: false).present?
  end

  def generate_history_for_status_changes
    StatusChangedHistory::CreatePurchaseOrderStatus.call(order: self , order_status: order_status, changed_by: changed_by)
  end
end
