class DhPurchaseOrder < ApplicationRecord
  audited
  has_many :line_items, as: :itemable
  # has_many :payment
  # has_one :address
  # belongs_to :supplier
  belongs_to :warehouse
  belongs_to :staff, optional: true
  has_many :failed_qcs, as: :failable
  has_many :stock_changes, as: :stock_changeable
  has_many :purchase_order_status, as: :orderable, class_name: 'PurchaseOrderStatus'
  # has_many :boxes, dependent: :destroy
  has_many :boxes, dependent: :destroy, as: :boxable, class_name: 'Box'

  has_many :box_line_items, through: :boxes
  # has_many :box_line_items, through: :_boxes

  attr_accessor :changed_by

  validates :warehouse_id, :quantity, :total_price, presence: true

  after_update :change_purchase_order_status, if: :saved_change_to_order_status?
  after_update :update_wh_variant_quantity, if: :saved_change_to_order_status?

  enum order_status:
         {
           order_placed: 0,
           order_confirmed: 1,
           ready_to_ship: 2,
           in_transit: 3,
           received_to_dh: 4,
           completed: 5,
           reconcilation_pending: 6,
         }

  def self.getOrderStatus(status)
    self.order_statuses[status]
  end

  def change_purchase_order_status
    StatusChangedHistory::CreatePurchaseOrderStatus.call(order: self, order_status: order_status, changed_by: changed_by)
  end

  def item_quantity_available?(items)
    availability = [true]
    items.each do |item|
      line_item = line_items.find_by(id: item[:line_item_id])
      warehouse_variant = line_item.variant.warehouse_variants.find_by(warehouse: Warehouse.find_by(warehouse_type: 'central'))
      wv_location = warehouse_variant.warehouse_variants_locations.find_by(location_id: item[:location_id])
      if warehouse_variant.available_quantity < item[:quantity] || wv_location.quantity < item[:quantity]
        availability << false
      end
    end

    availability
  end

  def update_wh_variant_quantity
    line_items.each do |item|
      warehouse_variant = item.variant.warehouse_variants.find_by(warehouse: Warehouse.find_by(warehouse_type: 'central'))

      case order_status
      when 'ready_to_ship'
        if (warehouse_variant.available_quantity - item.send_quantity).negative?
          Rails.logger.error "\nAvailable_quantity is being negative for sku = #{item.variant.sku} and warehouse_variant_id: #{warehouse_variant.id}. Action: Pack and Line_Item_id: #{item.id}\n"
        end
        warehouse_variant.update!(available_quantity: warehouse_variant.available_quantity - item.send_quantity,
                                  packed_quantity: warehouse_variant.packed_quantity + item.send_quantity)
        warehouse_variant.save_stock_change('sto_pack', item.send_quantity, item.itemable, 'available_quantity_change', 'packed_quantity_change')
      when 'in_transit'
        if (warehouse_variant.packed_quantity - item.send_quantity).negative?
          Rails.logger.error "\nPacked_quantity is being negative for sku = #{item.variant.sku} and warehouse_variant_id: #{warehouse_variant.id}. Action: Dispatch and Line_Item_id: #{item.id}\n"
        end
        warehouse_variant.update!(packed_quantity: warehouse_variant.packed_quantity - item.send_quantity,
                                  in_transit_quantity: warehouse_variant.in_transit_quantity + item.send_quantity)
        warehouse_variant.save_stock_change('sto_in_transit', item.send_quantity, item.itemable, 'packed_quantity_change', 'in_transit_quantity_change')
      when 'received_to_dh'
        if (warehouse_variant.in_transit_quantity - item.send_quantity).negative?
          Rails.logger.error "\nIn_transit_quantity is being negative for sku = #{item.variant.sku} and warehouse_variant_id: #{warehouse_variant.id}. Action: Receive and Line_Item_id: #{item.id}\n"
        end
        warehouse_variant.update!(in_transit_quantity: warehouse_variant.in_transit_quantity - item.send_quantity)
        warehouse_variant.save_stock_change('sto_receive_to_dh', item.send_quantity, item.itemable, 'in_transit_quantity_change', nil)
      end
    end
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

  def update_reconcilation_status(changed_by)
    return unless reconcilation_pending?

    self.changed_by = changed_by
    completed! unless failed_qcs.where(is_settled: false).present?
  end
end
