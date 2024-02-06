class CustomerOrder < ApplicationRecord
  before_validation :update_order_status, on: :create
  before_create :generate_pin, :check_cart_items
  before_save :order_status_change, if: :will_save_change_to_order_status_id?
  before_save :update_inventory, if: :will_save_change_to_order_status_id?
  after_create :update_distributor
  after_create :coupon_update, :promotion_create
  after_save :customer_pay_status
  validate :rider_changeable?

  ###############
  # Associations
  ###############

  belongs_to :customer_device, optional: true
  belongs_to :partner, optional: true
  belongs_to :customer, polymorphic: true
  has_many :shopoth_line_items, dependent: :destroy
  has_many :payments
  belongs_to :warehouse, optional: true
  belongs_to :distributor, optional: true
  belongs_to :billing_address, class_name: 'Address', optional: true
  belongs_to :shipping_address, class_name: 'Address', optional: true
  belongs_to :status, class_name: 'OrderStatus', foreign_key: :order_status_id
  has_one :invoice
  has_many :customer_care_reports
  has_many :return_customer_orders
  has_many :customer_order_status_changes
  belongs_to :rider, optional: true
  has_many :user_promotions
  belongs_to :promotion, optional: true
  belongs_to :customer_orderable, polymorphic: true
  has_one :coupon
  has_one :partner_margin
  has_many :stock_changes, as: :stock_changeable
  has_many :aggregate_returns
  has_many :aggregated_transaction_customer_orders
  has_many :aggregated_payment_customer_orders
  has_one :warehouse_margin
  has_many :notifications, as: :user_notifiable
  has_many :reviews, dependent: :destroy
  has_many :customer_order_promotions
  has_one :distributor_margin, dependent: :restrict_with_exception
  has_one :challan_line_item, dependent: :restrict_with_exception
  has_one :challan, through: :challan_line_item
  has_one :return_challan_line_item, as: :orderable, class_name: 'ReturnChallanLineItem', dependent: :restrict_with_exception
  has_one :return_challan, through: :return_challan_line_item

  attr_accessor :changed_by, :cart, :coupon_discount, :promotion_ids

  ###############
  # Enumerable
  ###############
  enum order_type: { organic: 0, induced: 1 }
  enum pay_type: { online_payment: 0, cash_on_delivery: 1, wallet_payment: 2, bkash_payment: 3, nagad_payment: 4, emi_payment: 5 }
  enum pay_status: {
    non_extended: 0,
    customer_paid: 1,
    partner_paid: 2,
    extended: 3,
    extension_expired: 4,
    dh_received: 5,
    payment_failed: 6
  }
  enum shipping_type: { home_delivery: 0, express_delivery: 1, pick_up_point: 2 }
  enum business_type: { b2c: 0, b2b: 1 }
  DELIVERY_CHARGE = {
    pick_up_point: 0,
    home_delivery: 40,
    express_delivery: 70,
  }.freeze

  ###############
  # Validations
  ###############
  # TODO: Custom validation to check presence of shipping_address or partner
  validates :name, presence: true, format: { with: /\A[a-zA-Z0-9.\s]+\Z/ }, on: :create
  validates :partner_id, presence: true, if: :pick_up_point?
  validate :check_customer_type, if: :pick_up_point?, on: :save
  validate :validate_pick_up_point_for_b2c, if: :b2b?

  ###########
  # Scopes
  ###########
  scope :completed_orders, ->(current_user_id, completed_status_id) { where('customer_id = ? AND order_status_id IN(?)', current_user_id, completed_status_id) }
  scope :orders_date_range, ->(time_filter) { where('created_at > ?', time_filter) }
  scope :with_no_discount, -> { where(total_discount_amount: 0.0) }

  def b2b_order_value
    return 0 if is_customer_paid?

    paid_amount = payments&.where(status: :successful, paymentable: customer)&.sum(:currency_amount)
    total_price - paid_amount
  end

  def frontend_id
    id.to_s.rjust(7, '0').to_s
  end

  def backend_id
    id.to_s.rjust(7, '0').to_s
  end

  def shopoth_line_items_total_price
    shopoth_line_items.sum(&:sub_total)
  end

  def completed_order_status_date
    customer_order_status_changes.where(
      order_status_id: OrderStatus.getOrderStatus(OrderStatus.order_types[:completed]),
    ).last&.created_at
  end

  def delivered_to_partner_order_status_date
    customer_order_status_changes.where(
      order_status_id: OrderStatus.getOrderStatus(OrderStatus.order_types[:delivered_to_partner])
    ).last&.created_at
  end

  def prev_status
    customer_order_status_changes.last(2).first
  end

  def returnable?
    return false if emi_payment?
    return false unless refundable?
    return false if total_discount_amount.positive?
    return false if return_customer_orders.packed.where.not(return_status: :cancelled).count > 0

    return_orders_count = return_customer_orders.unpacked.where.not(return_status: :cancelled).sum(:quantity)
    return false if return_orders_count >= item_count

    variants = shopoth_line_items.map(&:variant)
    return false unless variants.compact.present?
    return false if variants.map(&:product).compact.map(&:is_refundable).all?(false)
    return false if non_refundable_item_count + return_orders_count >= item_count

    true
  end

  def refundable?
    (status.completed? || status.partially_returned?) && ((completed_order_status_date + 7.day) >= Date.today)
  end

  def return_all_unpacked_items?
    return_customer_orders.unpacked.where.not(return_status: %w(initiated in_partner cancelled)).sum(:quantity) == item_count
  end

  def completed_within_seven_days?
    return false unless status.completed? || status.partially_returned?
    return false unless completed_order_status_date + 7.day >= Date.today

    true
  end

  def aggregate_return_create
    aggr_return = aggregate_returns.find_by(refunded: false)
    return aggr_return if aggr_return.present?

    aggregate_returns.create!(warehouse: warehouse, distributor: distributor)
  end

  def non_refundable_item_count
    shopoth_line_items.joins(variant: :product).
      where('products.is_refundable = false').distinct.sum(&:quantity)
  end

  def cancellable
    statuses = %w(delivered_to_partner completed cancelled sold_to_partner
                        in_transit_cancelled packed_cancelled returned_from_customer
                        partially_returned returned_from_partner cancelled_at_dh
                        cancelled_at_in_transit_to_dh)

    !statuses.include?(status.order_type)
  end

  def first_order?
    first_order = customer.customer_orders.order(created_at: :asc).first
    return true if first_order.nil? || (first_order.id == id)

    false
  end

  def update_wv_and_stock_change
    ActiveRecord::Base.transaction do
      shopoth_line_items.each do |line_item|
        stock_option = stock_change_option(status.order_type)
        warehouse_variant = WarehouseVariant.find_by!(warehouse: warehouse, variant: line_item.variant)
        if eval("warehouse_variant.#{stock_option[:decrease]} - line_item.quantity").negative?
          Rails.logger.error "\nQuantity is being negative for warehouse_variant_id: #{warehouse_variant.id}"
          fail StandardError, "Quantity is being negative"
        end
        eval("warehouse_variant.update!(
          #{stock_option[:decrease]}: warehouse_variant.#{stock_option[:decrease]} - line_item.quantity,
          #{stock_option[:increase]}: warehouse_variant.#{stock_option[:increase]} + line_item.quantity,
        )")
        warehouse_variant.save_stock_change(stock_option[:transaction_type], line_item.quantity, self,
          stock_option[:decrease].concat('_change'), stock_option[:increase].concat('_change'))
      end
    end
  end

  private

  def stock_change_option(co_status)
    case co_status
    when 'cancelled_at_in_transit_to_fc'
      return { transaction_type: 'cancelled_at_in_transit_to_fc', decrease: 'return_in_dh_quantity',
        increase: 'return_in_transit_to_fc_quantity' }
    when 'packed_cancelled'
      return { transaction_type: 'return_order_location_pending', decrease: 'return_in_transit_to_fc_quantity',
        increase: 'return_location_pending_quantity' }
    when 'in_transit_to_dh'
      return { transaction_type: 'in_transit_to_dh', decrease: 'ready_to_ship_from_fc_quantity',
        increase: 'in_transit_to_dh_quantity' }
    when 'ready_to_shipment'
      return { transaction_type: 'ready_to_ship', decrease: 'in_transit_to_dh_quantity',
               increase: 'ready_to_ship_quantity' }
    # if order is cancelled_at_in_transit_to_dh status is updated to cancelled_at_dh before challan receive
    when 'cancelled_at_dh'
      return { transaction_type: 'cancelled_at_in_transit_to_dh',
               decrease: 'in_transit_to_dh_quantity', increase: 'return_in_dh_quantity', }
    end
  end

  def update_order_status
    self.status = OrderStatus.getOrderStatus(OrderStatus.order_types[:order_placed])
  end

  def create_order_invoice
    create_invoice
  end

  def generate_pin
    self.pin = rand.to_s[2..5]
  end

  def order_status_change
    if id.present?
      customer_order_status_changes.create!(order_status_id: status&.id, changed_by_id: changed_by&.id,
                                            changed_by_type: changed_by&.class&.to_s)
      if b2c?
        CreateNotification.call(
          user: customer,
          message: Notification.get_notification_message(self),
          order: self,
          )
      end
    end
  end

  def update_inventory
    if status.cancelled?
      prev_status = OrderStatus.find(order_status_id_in_database)
      if prev_status.order_placed? || prev_status.order_confirmed?
        shopoth_line_items.each do |line_item|
          warehouse_variant = WarehouseVariant.find_by!(warehouse: warehouse, variant: line_item.variant)
          warehouse_variant.update!(
            available_quantity: warehouse_variant.available_quantity + line_item.quantity,
            booked_quantity: warehouse_variant.booked_quantity - line_item.quantity,
          )
          warehouse_variant.save_stock_change('cancel_from_order_placed', line_item.quantity,
            line_item.customer_order, 'booked_quantity_change', 'available_quantity_change')
        end

      elsif prev_status.packed_cancelled?
        shopoth_line_items.each do |line_item|
          warehouse_variant = WarehouseVariant.find_by!(warehouse: warehouse, variant: line_item.variant)

          warehouse_variant.update!(
            available_quantity: warehouse_variant.available_quantity + line_item.quantity,
            return_location_pending_quantity: warehouse_variant.return_location_pending_quantity - line_item.quantity,
          )
          warehouse_variant.save_stock_change('unpack_a_cancelled_customer_order', line_item.quantity,
                                              line_item.customer_order, 'return_location_pending_quantity_change',
                                              'available_quantity_change')
        end
      end
    end
    # Increasing product sell_count
    if status.completed?
      shopoth_line_items.each do |line_item|
        product = line_item&.variant&.product
        product&.update(sell_count: (product.sell_count + line_item.quantity))
      end
    end

    if status.cancelled_at_dh?
      prev_status = OrderStatus.find(order_status_id_in_database)

      if prev_status.ready_to_shipment?
        shopoth_line_items.each do |line_item|
          warehouse_variant = WarehouseVariant.find_by!(warehouse: warehouse, variant: line_item.variant)
          warehouse_variant.update!(
            return_in_dh_quantity: warehouse_variant.return_in_dh_quantity + line_item.quantity,
            ready_to_ship_quantity: warehouse_variant.ready_to_ship_quantity - line_item.quantity,
          )
          warehouse_variant.save_stock_change('cancelled_at_dh', line_item.quantity,
                                              line_item.customer_order, 'ready_to_ship_quantity_change',
                                              'return_in_dh_quantity_change')
        end
      elsif prev_status.in_transit_cancelled?
        shopoth_line_items.each do |line_item|
          warehouse_variant = WarehouseVariant.find_by!(warehouse: warehouse, variant: line_item.variant)
          warehouse_variant.update!(
            return_in_transit_quantity: warehouse_variant.return_in_transit_quantity - line_item.quantity,
            return_in_dh_quantity: warehouse_variant.return_in_dh_quantity + line_item.quantity,
          )
          warehouse_variant.save_stock_change('cancelled_in_transit_received', line_item.quantity,
                                              line_item.customer_order, 'return_in_transit_quantity_change',
                                              'return_in_dh_quantity_change')
        end
      end
    end

    # cancel in transit
    if status.in_transit_cancelled?
      prev_status = OrderStatus.find(order_status_id_in_database)
      if prev_status.in_transit?
        shopoth_line_items.each do |line_item|
          warehouse_variant = WarehouseVariant.find_by!(warehouse: warehouse, variant: line_item.variant)
          warehouse_variant.update!(
            return_in_transit_quantity: warehouse_variant.return_in_transit_quantity + line_item.quantity,
            in_transit_quantity: warehouse_variant.in_transit_quantity - line_item.quantity,
          )
          warehouse_variant.save_stock_change('cancelled_in_transit', line_item.quantity,
            line_item.customer_order, 'in_transit_quantity_change', 'return_in_transit_quantity_change')
        end
      end
    end

    # packed cancel from fc
    if status.packed_cancelled?
      prev_status = OrderStatus.find(order_status_id_in_database)
      if prev_status.ready_to_ship_from_fc?
        shopoth_line_items.each do |line_item|
          warehouse_variant = WarehouseVariant.find_by!(warehouse: warehouse, variant: line_item.variant)
          warehouse_variant.update!(
            return_location_pending_quantity: warehouse_variant.return_location_pending_quantity + line_item.quantity,
            ready_to_ship_from_fc_quantity: warehouse_variant.ready_to_ship_from_fc_quantity - line_item.quantity,
          )
          warehouse_variant.save_stock_change('return_order_location_pending', line_item.quantity,
            line_item.customer_order, 'ready_to_ship_from_fc_quantity_change', 'return_location_pending_quantity_change')
        end
      end
    end
  end

  def coupon_update
    coupon = Coupon.find_by(code: coupon_code)
    unless coupon.present?
      customer.coupon_users.first&.update!(is_expired: true) if first_order? && b2c?
      return nil
    end
    usable = coupon.usable.nil? ? customer : coupon.usable
    discount = coupon_discount || 0
    if (coupon.first_registration? && first_order?) || coupon.multi_user?
      discount_amount = if coupon.percentage?
                          max_check = (total_price * coupon.discount_amount) / 100
                          max_check > coupon.max_limit ? coupon.max_limit : max_check
                        else
                          coupon.discount_amount
                        end
      CouponUser.create(user_id: customer.id,
                        coupon_id: coupon.id,
                        code: coupon.code,
                        discount_amount: discount_amount,
                        customer_order_id: id)

    else
      return if coupon.first_registration?

      coupon.update_columns(is_used: true, cart_value: cart_total_price, discount_amount: discount,
                            customer_order_id: id, usable_id: usable&.id, usable_type: usable&.class.to_s)
    end
  end

  def promotion_create
    return if promotion_ids.blank?

    promotion_ids.each { |p| customer_order_promotions.create!(promotion_id: p) }
  end

  def customer_pay_status
    return true if b2b?

    update_column(:is_customer_paid, true) if customer_paid? && pay_type != 'cash_on_delivery'
  end

  def check_cart_items
    current_cart = Cart.find_by(id: cart.id)
    if current_cart.present? && current_cart.shopoth_line_items.present?
      update_shopoth_line_items(current_cart)
    else
      errors.add(:base, 'Cart can not empty!')
      raise ActiveRecord::Rollback, 'Cart can not empty!'
    end
  end

  def update_shopoth_line_items(current_cart)
    flag = false
    current_cart.shopoth_line_items.each do |item|
      flag = true if item.customer_order_id.present?
    end
    if flag == false
      self.shopoth_line_items = current_cart.shopoth_line_items
    else
      errors.add(:base, 'Already order exists')
      raise ActiveRecord::Rollback, 'Order exists!'
    end
  end

  def check_customer_type
    return true if b2b?

    if customer&.shopoth? && Warehouse.find_by(id: warehouse_id).warehouse_type == Warehouse::WAREHOUSE_TYPES[:member]
      errors.add(:base, 'Not allowed to order under this partner')
      fail ActiveRecord::Rollback, 'Customer is not allowed to order under this partner'
    else
      true
    end
  end

  def update_distributor
    distributor_id = if shipping_type == 'pick_up_point'
                       partner&.route&.distributor_id
                     else
                       warehouse.distributors.where(home_delivery: true)&.first&.id
                     end
    update_columns(distributor_id: distributor_id)
  end

  def rider_changeable?
    statuses = OrderStatus.fetch_statuses(%w(ready_to_ship_from_fc in_transit_to_dh ready_to_shipment))
    return unless will_save_change_to_rider_id? && !statuses.include?(status)

    # Rider can only be changed when status will be on ready_to_ship_from_fc or in_transit_to_dh or ready_to_shipment status.
    errors.add(:rider_id, "can't be changed for non changeable status.")
  end

  def validate_pick_up_point_for_b2c
    errors.add(:shipping_type, "only pick up point is acceptable for b2b order") if b2b? && !pick_up_point?
  end
end
