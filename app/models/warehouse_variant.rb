class WarehouseVariant < ApplicationRecord
  belongs_to :variant
  belongs_to :warehouse
  has_many :warehouse_variants_locations
  has_many :locations, through: :warehouse_variants_locations
  has_many :stock_changes

  validates :warehouse_id, :variant_id, :booked_quantity, :available_quantity, :packed_quantity, presence: true
  validates_uniqueness_of  :variant_id, scope: :warehouse_id, message: "already exit in this warehouse"
  # after_update :positive_quantity_check

  def self.stock_availability(current_cart, warehouse_id)
    unavailable = WarehouseVariant.quantity_check(current_cart, warehouse_id)
    if unavailable.empty?
      { available: true }
    else
      products = Variant.where(id: unavailable).joins(:product).pluck(:title)
      { available: false, items: products }
    end
  end

  def self.quantity_check(current_cart, warehouse_id)
    unavailable = []
    current_cart.shopoth_line_items.each do |line_item|
      variant = line_item.variant.id
      warehouse_variant = WarehouseVariant.find_by(variant_id: variant, warehouse_id: warehouse_id)
      unavailable << variant if line_item.quantity > warehouse_variant.available_quantity
    end
    unavailable
  end

  def self.stock_update(items, warehouse_id)
    wh_variants = WarehouseVariant.group_by_wh_variant(items, warehouse_id)
    wh_variants.each do |wh_v|
      if (wh_v['wv_id'].available_quantity - wh_v['qty']).negative?
        Rails.logger.error "\nAvailable_quantity is being negative warehouse_variant_id: #{wh_v['wv_id'].id}.
             Action: Order_place, customer order: #{wh_v['stock_changeable'].id}\n"
      end
      wh_v['wv_id'].update!(available_quantity: wh_v['wv_id'].available_quantity - wh_v['qty'],
                            booked_quantity: wh_v['wv_id'].booked_quantity + wh_v['qty'])
      wh_v['wv_id'].save_stock_change('order_placed', wh_v['qty'], wh_v['stock_changeable'],
                                      'available_quantity_change', 'booked_quantity_change')
    end
  end

  def save_stock_change(transaction_type, quantity, stock_changeable, field_decrease, field_increase)
    stock_change = stock_changes.new(
      available_quantity: available_quantity,
      booked_quantity: booked_quantity,
      packed_quantity: packed_quantity,
      in_transit_quantity: in_transit_quantity,
      in_partner_quantity: in_partner_quantity,
      blocked_quantity: blocked_quantity,
      warehouse_id: warehouse_id,
      variant_id: variant_id,
      stock_transaction_type: transaction_type,
      quantity: quantity,
      stock_changeable: stock_changeable,
      qc_pending_quantity: qc_pending_quantity,
      qty_qc_failed_quantity: qty_qc_failed_quantity,
      qly_qc_failed_quantity: qly_qc_failed_quantity,
      location_pending_quantity: location_pending_quantity,
      return_in_partner_quantity: return_in_partner_quantity,
      return_in_transit_quantity: return_in_transit_quantity,
      return_in_dh_quantity: return_in_dh_quantity,
      return_in_transit_to_fc_quantity: return_in_transit_to_fc_quantity,
      return_qc_pending_quantity: return_qc_pending_quantity,
      return_location_pending_quantity: return_location_pending_quantity,
      return_qc_failed_quantity: return_qc_failed_quantity,
      ready_to_ship_from_fc_quantity: ready_to_ship_from_fc_quantity,
      in_transit_to_dh_quantity: in_transit_to_dh_quantity,
      ready_to_ship_quantity: ready_to_ship_quantity,
    )
    stock_change[field_decrease] = -quantity if field_decrease
    stock_change[field_increase] = quantity if field_increase
    stock_change.garbage_quantity = quantity if transaction_type == 'garbage_blocked_sku'
    stock_change.save!
  end

  def self.group_by_wh_variant(items, wh_id)
    wh_variant = []
    items.each do |item|
      wv = WarehouseVariant.find_by(variant_id: item.variant.id, warehouse_id: wh_id)
      wh_variant = WarehouseVariant.detect_wh_variant(wv, wh_variant, item.quantity, item.customer_order)
    end
    wh_variant
  end

  def self.wh_variant_multi_location(items, wh_id)
    wh_variant = []
    items.each do |item|
      wv = WarehouseVariant.find_by(variant_id: item[:variant_id], warehouse_id: wh_id)
      wh_variant = WarehouseVariant.detect_wh_variant(wv, wh_variant, item[:quantity], item[:customer_order])
    end
    wh_variant
  end

  def self.detect_wh_variant(whv, wh_vrnt, qty, stock_changeable)
    found = wh_vrnt.detect { |x| x['wv_id'] == whv }
    if found
      found['qty'] += qty
    else
      wh_vrnt << { 'wv_id' => whv,
                   'qty' => qty,
                   'stock_changeable' => stock_changeable, }
    end
    wh_vrnt
  end

  private

  def positive_quantity_check
    if available_quantity.negative? || booked_quantity.negative? || packed_quantity.negative? || in_transit_quantity.negative? || in_partner_quantity.negative? || blocked_quantity.negative?
      # TODO: Need to send mail to developer and Tauhidul Islam vaiya when negative value arise
      # Mail Information will be WarehouseVariant object and Time.now
    end
  end
end
