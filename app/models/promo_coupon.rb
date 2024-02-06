class PromoCoupon < ApplicationRecord
  audited
  has_many :coupons, dependent: :destroy
  has_many :promo_coupon_rules, dependent: :destroy

  ###########################
  # Validation
  ###########################
  validates :title, :status, :order_type, :discount_type, :start_date, :end_date, presence: true
  validates :discount, presence: true
  validates :max_discount_amount, presence: true, if: :percentage?
  validate :start_must_be_before_end_date

  enum status: { inactive: 0, active: 1 }
  enum discount_type: { fixed: 0, percentage: 1 }
  enum order_type: { both: 0, induced: 1, organic: 2 }

  accepts_nested_attributes_for :promo_coupon_rules, reject_if: :all_blank, allow_destroy: true
  # Default scope:
  default_scope { where(is_deleted: false).order(id: :desc) }

  def running?
    status == 'active' && Time.now.in_time_zone('Asia/Dhaka').to_date.between?(start_date.to_date, end_date.to_date)
  end

  ###########################
  # Callbacks
  ###########################
  # after_create :generate_coupons

  def applicable?(cart, user, type, locations)
    return false if order_type != 'both' && type&.downcase != order_type
    return false if cart.shopoth_line_item_total < minimum_cart_value

    rules = promo_coupon_rules.group(:ruleable_type).pluck(:ruleable_type)
    return false if rules.count > 2

    applicable = []
    2.times do |i|
      rule_ids = promo_coupon_rules.where(ruleable_type: rules[i]).pluck(:ruleable_id)
      if %w(Variant Category Brand).include?(rules[i])
        flag = false
        case rules[i]
        when 'Variant'
          cart.shopoth_line_items.map(&:variant_id).each do |variant_id|
            flag = true if rule_ids.include?(variant_id)
          end
        when 'Category'
          cart.shopoth_line_items.map(&:leaf_category_id).each do |category_id|
            flag = true if rule_ids.include?(category_id)
          end
        when 'Brand'
          cart.shopoth_line_items.map(&:brand_id).each do |brand_id|
            flag = true if rule_ids.include?(brand_id)
          end
        end
        applicable << flag
      elsif %w(Warehouse User Partner District Thana Area).include?(rules[i])
        case rules[i]
        when 'Warehouse'
          applicable << rule_ids.include?(locations[:warehouse]&.id)
        when 'User'
          applicable << rule_ids.include?(user&.id)
        when 'Partner'
          applicable << rule_ids.include?(locations[:partner]&.id)
        when 'District'
          applicable << rule_ids.include?(locations[:district]&.id)
        when 'Thana'
          applicable << rule_ids.include?(locations[:thana]&.id)
        when 'Area'
          applicable << rule_ids.include?(locations[:area]&.id)
        end
      else
        applicable << true
      end
    end
    applicable.size == 2 && applicable.all?(true)
  end

  def apply_discount(cart, coupon, user)
    amount = discount_calculation(cart)
    # TODO: Implement max discount between coupon and member discount.
    cart.cart_promotions.destroy_all if cart.cart_promotions&.size.to_i.positive?
    cart.update!(sub_total: cart.shopoth_line_item_total.to_f, cart_discount: amount.ceil,
                 coupon_code: coupon.code, user: user, cart_dis_type: 'promo_coupon')
  end

  def discount_calculation(cart)
    coupon_rule = promo_coupon_rules.find_by(ruleable_type: %w(Variant Category Brand))
    cart_total = if coupon_rule.present?
                   rule_ids = promo_coupon_rules.where(ruleable_type: coupon_rule.ruleable_type).pluck(:ruleable_id)
                   case coupon_rule.ruleable_type
                   when 'Variant'
                     cart.shopoth_line_items.where(variant_id: rule_ids).sum(&:sub_total)
                   when 'Category'
                     cart.shopoth_line_items.joins(:products).where('products.leaf_category_id IN (?)', rule_ids).sum(&:sub_total)
                   when 'Brand'
                     cart.shopoth_line_items.joins(:products).where('products.brand_id IN (?)', rule_ids).sum(&:sub_total)
                   end
                 else
                   cart.shopoth_line_item_total.to_f
                 end

    if discount_type == 'percentage'
      calculated_discount = (cart_total * (discount / 100))
      calculated_discount < max_discount_amount ? calculated_discount : max_discount_amount
    else
      discount <= cart_total ? discount : cart_total
    end
  end

  def create_coupons(rule_attributes)
    rule_types = rule_attributes.pluck(:ruleable_type)
    if rule_types.include?('User')
      rule_attributes.each do |rule|
        generate_coupons(1, rule[:ruleable_id], rule[:ruleable_type]) if rule[:ruleable_type] == 'User'
      end
    elsif rule_types.include?('Warehouse')
      rule_attributes.each do |rule|
        if rule[:ruleable_type] == 'Warehouse'
          generate_coupons(number_of_coupon, rule[:ruleable_id], rule[:ruleable_type])
        end
      end
    elsif rule_types.include?('Partner')
      rule_attributes.each do |rule|
        if rule[:ruleable_type] == 'Partner'
          generate_coupons(number_of_coupon, rule[:ruleable_id], rule[:ruleable_type])
        end
      end
    elsif rule_types.include?('District')
      rule_attributes.each do |rule|
        if rule[:ruleable_type] == 'District'
          generate_coupons(number_of_coupon, rule[:ruleable_id], rule[:ruleable_type])
        end
      end
    elsif rule_types.include?('Thana')
      rule_attributes.each do |rule|
        if rule[:ruleable_type] == 'Thana'
          generate_coupons(number_of_coupon, rule[:ruleable_id], rule[:ruleable_type])
        end
      end
    elsif rule_types.include?('Area')
      rule_attributes.each do |rule|
        if rule[:ruleable_type] == 'Area'
          generate_coupons(number_of_coupon, rule[:ruleable_id], rule[:ruleable_type])
        end
      end
    else
      generate_coupons(number_of_coupon, nil, nil)
    end
  end

  private

  def generate_coupons(number_of_coupon, ruleable_id, ruleable_type)
    number_of_coupon.times { coupons.create!(usable_id: ruleable_id, usable_type: ruleable_type) }
  end

  def start_must_be_before_end_date
    errors.add(:start_date, 'must be before end date') unless start_date <= end_date
  end
end
