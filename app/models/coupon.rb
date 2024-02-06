class Coupon < ApplicationRecord
  audited if: :staff_coupon?
  belongs_to :promotion, optional: true
  belongs_to :promo_coupon, optional: true
  belongs_to :usable, polymorphic: true, optional: true
  belongs_to :return_customer_order, optional: true
  belongs_to :customer_order, optional: true
  belongs_to :aggregate_return, optional: true
  has_many :coupon_users, dependent: :restrict_with_error
  has_one :coupon_category
  accepts_nested_attributes_for :coupon_category,
                                reject_if: :all_blank,
                                allow_destroy: true

  ###########################
  # Validations
  ###########################
  validates :code, uniqueness: true
  validates :max_limit, presence: true, numericality: { greater_than: 0 }, if: :percentage?

  ###########################
  # Callbacks
  ###########################
  before_create :generate_unique_id, unless: -> { :first_registration? || :multi_user? }
  after_create :valid_coupon?

  enum coupon_type: { promotion: 0, first_registration: 1, return_voucher: 2, multi_user: 3, acquisition: 4 }
  enum discount_type: { fixed: 0, percentage: 1 }
  enum sku_inclusion_type: { not_applicable: 0, included: 1, excluded: 2 }

  ###########################
  # Scopes
  ###########################
  default_scope { where(is_deleted: false).order(id: :desc) }
  scope :unused, -> { where(is_used: false) }
  scope :active, -> { where(is_active: true) }
  scope :running, ->(current_date) { where('DATE(start_at) <= :current_date AND DATE(end_at) >= :current_date', current_date: current_date) }
  def self.calculate_coupon(coupon, cart, user_domain = '', warehouse, user)
    discount_context = Discounts::DiscountCalculation.call(cart: cart,
                                                           member: user_domain,
                                                           coupon: coupon,
                                                           warehouse: warehouse,
                                                           user: user)
    Coupon.calculate_discount(discount_context.max_discount, discount_context.total_discount)
  end

  def valid_coupon?
    # fail 'Coupon code length must be 6 character' unless code.gsub(/\s+/, '').length == 6
    fail 'Coupon code should alphanumeric' unless code.match(/\W/).nil? # Checking code is alphanumeric
  end

  def self.calculate_discount(max_discount, total_discount)
    if max_discount[:type] == 'promo' && max_discount[:applicable] == true
      Coupon.coupon_discount_params(total_discount[:coupon_code], total_discount[:discount],
                                    false, total_discount[:promotion], total_discount[:dis_type])
    elsif max_discount[:type] == 'voucher'
      Coupon.coupon_discount_params(total_discount[:coupon_code], total_discount[:discount],
                                    true, total_discount[:promotion], total_discount[:dis_type])
    elsif max_discount[:type] == 'member'
      Coupon.coupon_discount_params(nil, total_discount[:discount], false,
                                    total_discount[:promotion], total_discount[:dis_type])
    else
      Coupon.coupon_discount_params(total_discount[:coupon_code], total_discount[:discount],
                                    false, total_discount[:promotion], total_discount[:dis_type])
    end
  end

  def self.coupon_discount_params(code, discount, is_return_coupon, promotion, dis_type)
    {
      discount: discount,
      returned: is_return_coupon,
      promotion: promotion,
      coupon_code: code,
      dis_type: dis_type,
    }
  end

  def generate_unique_id
    code = SecureRandom.alphanumeric(6).upcase
    self.code = code
  end

  def valid_for_first_time?(user)
    return false unless running?
    return false unless first_registration? || acquisition?
    return false unless user.customer_orders.blank?

    true
  end

  def running?
    return false unless is_active

    return true if acquisition?

    start_date = Time.zone.parse(start_at.to_s)
    end_date = Time.zone.parse(end_at.to_s)
    Time.now.in_time_zone('Asia/Dhaka').between?(start_date, end_date)
  end

  def self.fetch_coupon(coupon_types)
    Coupon.where(coupon_type: coupon_types)
  end

  def valid_for_multi_user?(user)
    return false unless running?
    return false unless multi_user?
    return false unless coupon_users.count < max_user_limit
    return false unless user.customer_orders.where(coupon_code: code).count < used_count

    true
  end

  def check_phone_numbers(user)
    return true unless phone_numbers.present?

    phone_numbers = self.phone_numbers.split(',').map(&:strip)
    return false unless phone_numbers.include?(user.phone)

    true
  end

  def coupon_variants
    skus = self.skus.split(',').map(&:strip)
    Variant.where(sku: skus)
  end

  def check_sku(cart)
    return false unless skus.present?

    variants = coupon_variants
    if included?
      return false unless cart.shopoth_line_items.where(variant: variants).present?
    elsif excluded?
      count = 0
      cart.shopoth_line_items.each do |line_item|
        # check coupon validation for each cart item
        count += 1 if variants.include?(line_item.variant)
      end
      # if all of the cart items failed validation
      return false if count == cart.shopoth_line_items.count && !coupon_category.present?

    end

    true
  end

  def valid_for_category(cart)
    # if category if not present
    return false unless coupon_category.present?

    category_ids = coupon_category.category_ids.reject(&:empty?).map(&:to_i)
    count = 0
    invalid_sku_line_item_ids = []
    cart.shopoth_line_items.each do |line_item|
      product_category_ids = line_item.variant.product.product_categories.map(&:category_id)
      # check coupon validation for each cart item
      if ((product_category_ids & category_ids).present? && coupon_category.excluded?) ||
         ((product_category_ids & category_ids).blank? && coupon_category.included?)
        count += 1
        invalid_sku_line_item_ids << line_item.id
      end
    end
    # if all of the cart items failed validation
    valid_present = !(cart.shopoth_line_items.count - count).zero?
    if !skus.present?
      return false if count == cart.shopoth_line_items.count
    else
      valid_sku_line_item_ids = cart.shopoth_line_items.pluck(:id) - invalid_sku_line_item_ids
      value = excluded? ? check_same_sku(cart, valid_sku_line_item_ids) : (check_sku(cart) || valid_present)
      return false if value == false

    end
    true
  end

  def check_same_sku(cart, valid_sku_line_item_ids)
    sku_line_item_ids = cart.shopoth_line_items.where(variant_id: coupon_variants.pluck(:id)).pluck(:id)
    return false if (valid_sku_line_item_ids - sku_line_item_ids).empty?

    true
  end

  def staff_coupon?
    %w(promotion first_registration multi_user).include?(coupon_type)
  end
end
