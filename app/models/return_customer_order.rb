class ReturnCustomerOrder < ApplicationRecord
  audited
  include ImageVersions
  include Rails.application.routes.url_helpers
  before_create :assign_default_quantity

  belongs_to :customer_order
  belongs_to :partner, optional: true
  belongs_to :rider, optional: true
  belongs_to :shopoth_line_item, optional: true
  belongs_to :warehouse, optional: true
  belongs_to :distributor, optional: true
  has_many_attached :images
  has_one :coupon
  has_many :return_status_changes
  belongs_to :return_orderable, polymorphic: true, optional: true
  has_one :address, as: :addressable
  has_many :failed_qcs, as: :failable
  has_many :stock_changes, as: :stock_changeable
  belongs_to :aggregate_return, optional: true
  has_one :return_challan_line_item, as: :orderable, class_name: 'ReturnChallanLineItem', dependent: :restrict_with_exception
  has_one :return_challan, through: :return_challan_line_item

  validates :images, blob: { content_type: %w(image/jpg image/jpeg image/png image/webp), size_range: 1..5.megabytes }, if: :images
  validates :partner_id, presence: true, if: :to_partner?
  validates :sub_total, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, if: :unpacked?

  enum return_status: {
    initiated: 0,
    in_partner: 1,
    in_transit: 2,
    # sold_to_partner: 3,
    delivered_to_dh: 4,
    cancelled: 5,
    qc_pending: 6,
    relocation_pending: 7,
    # qc_failed: 8,
    completed: 9,
    in_transit_to_fc: 10,
  }

  enum qc_status: {
    pending: 0,
    passed: 1,
    failed: 2,
  }

  enum reason: {
    'product is received in damaged/defective/incomplete condition': 0,
    'product delivered is wrong': 1,
    'product is different from the description on the website or not as advertised': 2,
    'product arrives expired': 3,
    'branded product is unsealed': 4,
    'size or color is not a match': 5,
    'warranty documents are missing despite stating on the website': 6,
  }

  MAP_BN_REASON = {
    0 => 'পণ্যটি খতিগ্রস্ত/ত্রুটিপূর্ণ/অসম্পূর্ণ অবস্থায় গৃহীত হয়েছে',
    1 => 'ভুল পণ্য দেওয়া হয়েছে',
    2 => 'পণ্যটি ওয়েবসাইটে দেওয়া বর্ণনা কিংবা বিজ্ঞাপনের সাথে মিলছে না।',
    3 => 'পণ্যটির মেয়াদোত্তীর্ণ।',
    4 => 'ব্র্যান্ডেড পণ্যটির সিল ভাঙ্গা।',
    5 => 'সাইজ/রং মিলে নি।',
    6 => 'ওয়ারেন্টির কাগজ নেই যেটা ওয়েবসাইটে উল্লিখিত ছিল।',
  }.freeze

  ECOM_BN_REASON = {
    "পণ্যটি খতিগ্রস্ত/ত্রুটিপূর্ণ/অসম্পূর্ণ অবস্থায় গৃহীত হয়েছে": 0,
    "ভুল পণ্য দেওয়া হয়েছে": 1,
    "পণ্যটি ওয়েবসাইটে দেওয়া বর্ণনা কিংবা বিজ্ঞাপনের সাথে মিলছে না।": 2,
    "পণ্যটির মেয়াদোত্তীর্ণ।": 3,
    "ব্র্যান্ডেড পণ্যটির সিল ভাঙ্গা।": 4,
    "সাইজ/রং মিলে নি।": 5,
    "ওয়ারেন্টির কাগজ নেই যেটা ওয়েবসাইটে উল্লিখিত ছিল।": 6,
  }.freeze

  INITIATED_BY = {
    'CustomerCareAgent': 'কাস্টমার কেয়ার',
    'User': 'গ্রাহক',
    'Partner': 'পার্টনার',
    '': "",
  }.freeze

  EN_INITIATED_BY = {
    'CustomerCareAgent': 'Customer Care',
    'User': 'User',
    'Partner': 'Partner',
    '': "",
  }.freeze

  PICK_UP_CHARGE = {
    'from_home': 40,
    'to_partner': 0,
  }.freeze

  enum return_type: { undefined: 0, packed: 1, unpacked: 2 }
  enum form_of_return: { from_home: 0, to_partner: 1 }

  after_update :return_status_change, if: :saved_change_to_return_status?
  after_update :update_customer_order_status, if: :saved_change_to_return_status?
  attr_accessor :changeable

  def images_file=(file_arr)
    img_arr = file_arr.map do |file|
      {
        io: file[:tempfile],
        filename: file[:filename],
        content_type: file[:type],
      }
    end
    self.images = img_arr
  end

  def self.get_img_url(obj)
    Rails.application.routes.url_helpers.rails_representation_url(obj.variant(resize: '240x240').processed, only_path: true)
  end

  def backend_id
    id.to_s.rjust(7, '0').to_s
  end

  def calculate_coupon_amount
    return_orders = aggregate_return.return_customer_orders.where(refunded: false).
                    where.not(return_status: %i(cancelled initiated in_partner)).
                    joins(:return_status_changes).
                    where('return_status_changes.status = ? AND return_status_changes.created_at <= ?',
                          :in_transit, Time.now.utc.end_of_day)
    generate_coupon(return_orders.distinct) if return_orders.present?
  end

  def generate_coupon(return_orders)
    return_ids = return_orders.ids
    grand_total = aggregate_return.grand_total
    return if grand_total <= 0

    coupon = Coupon.create!(usable: customer_order.customer,
                            discount_amount: grand_total,
                            aggregate_return_id: aggregate_return.id,
                            coupon_type: :return_voucher,
                            code: SecureRandom.alphanumeric(6).upcase)
    return_orders.update_all(refunded: true)
    aggregate_return.update!(refunded: true)
    send_voucher_sms(return_ids, coupon)
  end

  def send_voucher_sms(return_orders, coupon)
    I18n.locale = :bn
    message = I18n.t('voucher_coupon', return_order_id: return_orders, coupon_code: coupon.code,
                                       amount: coupon.discount_amount.to_i)
    sms_context = SmsManagement::SendMessage.call(phone: customer_order.phone, message: message)
    if sms_context.success?
      Rails.logger.info '<<<<<<<<<<<<<<<<<SMS SENT>>>>>>>>>>>>>>>>>>'
    else
      Rails.logger.info '<<<<<<<<<<<<<<<<<SMS NOT SENT>>>>>>>>>>>>>>>>>>'
    end
  end

  def customer_return_status(stat)
    case stat
    when 'initiated'
      'Initiated'
    when 'in_partner'
      'Received by Store'
    when 'in_transit', 'delivered_to_dh', 'qc_pending', 'relocation_pending', 'completed'
      'Refunded'
    when 'cancelled'
      'Cancelled'
    else
      ''
    end
  end

  # TODO: Need to replace status specific words with Bangla text.
  def bn_customer_return_status(return_status)
    case return_status
    when 'initiated'
      'Initiated'
    when 'in_partner'
      'Received by Store'
    when 'in_transit', 'delivered_to_dh', 'qc_pending', 'relocation_pending', 'completed'
      'Refunded'
    when 'cancelled'
      'Cancelled'
    else
      ''
    end
  end

  def update_customer_order_status
    return unless in_transit? && unpacked?

    if customer_order.return_all_unpacked_items?
      customer_order.update(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:returned_from_customer]),
                            changed_by: changeable)
    elsif customer_order.status.completed?
      customer_order.update(status: OrderStatus.getOrderStatus(OrderStatus.order_types[:partially_returned]),
                            changed_by: changeable)
    end
  end

  def return_status_change
    return_status_changes.find_or_create_by(status: return_status, changeable_id: changeable.id,
                                            changeable_type: changeable.class.to_s)
  end


  def update_inventory_and_stock_changes(increase_field, decrease_field = nil, line_item = nil, quantity = nil, failed_qc = nil)
    Rails.logger.info("Start Return Order update_inventory_and_stock_changes for fields: #{increase_field} #{decrease_field}")
    if quantity.present? && failed_qc.present?
      update_inventory_and_stock_changes_for_line_item(nil, increase_field, decrease_field, quantity, failed_qc)
    elsif line_item.present?
      update_inventory_and_stock_changes_for_line_item(line_item, increase_field, decrease_field)
    elsif packed?
      customer_order.shopoth_line_items.each do |line_item|
        update_inventory_and_stock_changes_for_line_item(line_item, increase_field, decrease_field)
      end
    else
      update_inventory_and_stock_changes_for_line_item(shopoth_line_item, increase_field, decrease_field)
    end
    Rails.logger.info("End Return Order update_inventory_and_stock_changes for fields: #{increase_field} #{decrease_field}")
  end


  private
  def assign_default_quantity
    self.quantity = 1  if unpacked? && quantity.nil?
  end

  def update_inventory_and_stock_changes_for_line_item(line_item, increase_field, decrease_field, _quantity = nil, failed_qc = nil)
    _quantity = packed? ? line_item.quantity : self.quantity unless _quantity.present?
    variant = failed_qc.present? ? failed_qc&.variant : line_item&.variant
    warehouse_variant = customer_order.warehouse.warehouse_variants.find_by(variant: variant)

    query_string = ""
    query_string += "#{increase_field}:  warehouse_variant.#{increase_field} + _quantity" if increase_field.present?
    if decrease_field.present?
      query_string += ', ' if query_string.length > 0
      query_string += "#{decrease_field}:  warehouse_variant.#{decrease_field} - _quantity"
    end
    if decrease_field.present? && eval("warehouse_variant.#{decrease_field} - _quantity").negative?
      Rails.logger.error "\nQuantity is being negative for warehouse_variant_id: #{warehouse_variant.id}"
      fail StandardError, 'Quantity is being negative'
    end
    eval ("warehouse_variant.update!(#{query_string})")

    options = stock_transfer_type_options(increase_field, decrease_field)
    stock_changeable = failed_qc.present? ? failed_qc : self
    warehouse_variant.save_stock_change(options[:type], _quantity, stock_changeable, options[:fields][:desc], options[:fields][:inc])
  end

  def stock_transfer_type_options(field, desc_field = nil)
    case field
    when 'return_in_partner_quantity'
      desc = desc_field.present? ? "#{desc_field}_change" : nil
      return {type: 'return_order_in_partner', fields: {inc: 'return_in_partner_quantity_change', desc: desc}}
    when 'return_in_transit_quantity'
      if packed? && partner.present?
        return {type: 'return_order_in_transit', fields: {inc: 'return_in_transit_quantity_change', desc: 'return_in_partner_quantity_change'}}
      else
        return {type: 'return_order_in_transit', fields: {inc: 'return_in_transit_quantity_change', desc: nil}}
      end
    when 'return_in_dh_quantity'
      return {type: 'return_order_in_dh', fields: {inc: 'return_in_dh_quantity_change', desc: 'return_in_transit_quantity_change'}}
    when 'return_in_transit_to_fc_quantity'
      return {type: 'return_order_in_transit_to_fc', fields: {inc: 'return_in_transit_to_fc_quantity_change', desc: 'return_in_dh_quantity_change'}}
    when 'return_qc_pending_quantity'
      return {type: 'return_order_qc_pending', fields: {inc: 'return_qc_pending_quantity_change', desc: 'return_in_transit_to_fc_quantity_change'}}
    when 'return_qc_failed_quantity'
      return {type: 'return_order_qc_failed', fields: {inc: 'return_qc_failed_quantity_change', desc: 'return_qc_pending_quantity_change'}}
    when 'return_location_pending_quantity'
      return {type: 'return_order_location_pending', fields: {inc: 'return_location_pending_quantity_change', desc: 'return_qc_pending_quantity_change'}}
    when 'available_quantity'
      if desc_field == 'return_location_pending_quantity'
        return {type: 'location_assign_after_return_qc', fields: {inc: 'available_quantity_change', desc: "#{desc_field}_change"}}
      else
        return {type: 'received_for_failed_qc_sku', fields: {inc: 'available_quantity_change', desc: "#{desc_field}_change"}}
      end
    end
  end
end
