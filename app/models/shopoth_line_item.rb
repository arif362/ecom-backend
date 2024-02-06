class ShopothLineItem < ApplicationRecord
  belongs_to :variant
  belongs_to :cart, optional: true
  belongs_to :customer_order, optional: true
  belongs_to :promotion, optional: true
  belongs_to :location, optional: true
  has_many :return_customer_orders
  has_many :reviews, dependent: :destroy
  has_many :products, through: :variant
  belongs_to :sample_of, class_name: 'ShopothLineItem', optional: true
  has_many :samples, class_name: 'ShopothLineItem', foreign_key: :sample_for, dependent: :destroy
  has_many :line_item_locations
  delegate :leaf_category_id, :brand_id, :tenures, :emi_available?, to: :variant, allow_nil: true

  ###################
  # Validations:
  ###################
  validate :check_presence_of_cart_or_order
  validate :positive_quantity_check
  validate :restrict_update_quantity
  before_destroy :check_order
  validates_uniqueness_of :variant_id, scope: %i(cart_id customer_order_id), message: 'need to be unique.'

  default_scope { order('shopoth_line_items.created_at DESC') }

  def total_price
    price * quantity
  end

  def check_presence_of_cart_or_order
    if cart_id.nil? && customer_order_id.nil?
      errors.add(:base, 'Cart and order can not be empty at the same time')
    end
  end

  def effective_unit_price
    sub_total / quantity
  end

  def reviewed?
    return false if customer_order.blank?
    return false unless customer_order&.is_customer_paid? && completed_status_change?

    customer_order.customer.reviews.map(&:shopoth_line_item_id).include?(id)
  end

  def completed_status_change?
    completed_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
    customer_order&.customer_order_status_changes&.find_by(order_status: completed_status).present?
  end

  def returnable?
    return false unless variant.product&.is_refundable?
    return false if promotion&.rule == 'buy_x_get_y'

    return_count = return_customer_orders.where(shopoth_line_item_id: id).
                   where.not(return_status: :cancelled).size
    return false if return_count >= quantity

    true
  end

  def quantity_valid?(requested_quantity)
    return_count = return_customer_orders.where.not(return_status: :cancelled).sum(:quantity) + requested_quantity
    return false if return_count > quantity

    true
  end

  def available?(warehouse)
    return false unless warehouse.present?
    return false unless variant.product.present?

    warehouse_variant = variant.warehouse_variants.find_by(warehouse: warehouse)
    quantity <= (warehouse_variant&.available_quantity || 0)
  end

  private

  def check_order
    if customer_order.present? && cart.nil?
      errors.add(:base, 'can not be destroyed')
      throw :abort
      raise Error, "Can't delete item"
    end
  end

  def positive_quantity_check
    errors[:base] << 'Negative quantity is not acceptable.' unless quantity.positive?
  end

  def restrict_update_quantity
    errors.add(:base, 'can not be updated') if customer_order.present? && quantity_changed?
  end
end
