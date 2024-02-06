class Cart < ApplicationRecord
  # ShopothLineItems price checking using PriceCheckable concern.
  # include PriceCheckable

  belongs_to :user, optional: true
  belongs_to :partner, optional: true
  has_many :shopoth_line_items, dependent: :nullify
  belongs_to :promotion, optional: true
  has_many :cart_promotions, dependent: :destroy

  enum business_type: {b2c: 0, b2b: 1}

  validates :business_type, presence: true, uniqueness: {scope: :partner_id, message: 'Cart already exist'}, if: -> {partner_id.present?}

  def add_cart(variant, quantity, warehouse_id, business_type = 'b2c')
    current_item = shopoth_line_items.find_by(variant: variant, sample_for: nil)
    qty = current_item.present? ? current_item.quantity + quantity : quantity
    sku_promo = Discounts::SkuPromotions.call(variant: variant, quantity: qty, cart: self,
                                              line_item: current_item, warehouse_id: warehouse_id, business_type: business_type)
    sku_promo.result
  end

  def coupon_applicable?(order_type)
    coupon = Coupon.find_by(code: coupon_code, is_used: false)
    promo_coupon = coupon&.promo_coupon
    return if promo_coupon.blank?

    promo_coupon_rules = coupon.promo_coupon.promo_coupon_rules
    rule = promo_coupon_rules.find_by(ruleable_type: %w(Variant Category Brand))&.ruleable_type
    rule_ids = promo_coupon_rules.where(ruleable_type: rule)&.pluck(:ruleable_id)
    applicable = false
    case rule
    when 'Variant'
      shopoth_line_items.map(&:variant_id).each do |variant_id|
        applicable = true if rule_ids.include?(variant_id)
      end
    when 'Category'
      shopoth_line_items.map(&:leaf_category_id).each do |category_id|
        applicable = true if rule_ids.include?(category_id)
      end
    when 'Brand'
      shopoth_line_items.map(&:brand_id).each do |brand_id|
        applicable = true if rule_ids.include?(brand_id)
      end
    else
      applicable = true
    end
    applicable = false if promo_coupon.order_type != 'both' && order_type != promo_coupon.order_type
    applicable = false if shopoth_line_item_total < promo_coupon.minimum_cart_value
    return if coupon.promo_coupon&.running? && applicable

    update(coupon_code: nil, cart_discount: 0.0, cart_dis_type: nil)
  end

  def update_cart_attr(user_domain = '', warehouse, current_user)
    coupon = Coupon.find_by(code: coupon_code, is_used: false)
    cart_discount_update(user_domain, warehouse, coupon, current_user)
  end

  def total_items
    shopoth_line_items.to_a.sum(&:quantity)
  end

  def fetch_tenures
    shopoth_line_items.map(&:tenures).flatten.compact.uniq.sort
  end

  def check_emi_availability
    shopoth_line_items.map(&:emi_available?).any?(true)
  end

  def emi_applicable?(tenure)
    check_emi_availability && fetch_tenures.include?(tenure) && Configuration.find_by(key: 'available_tenors')&.version_config&.values&.include?(tenure)
  end

  def shopoth_line_item_total
    shopoth_line_items.sum(&:sub_total)
  end

  def shopoth_line_item_discount
    shopoth_line_items.to_a.sum(&:discount_amount)
  end

  def total_price
    cart_discount >= sub_total ? 0.0 : (sub_total - cart_discount)
  end

  def check_minimum_cart_value
    shopoth_line_item_total >= Configuration.min_cart_value
  end

  def calculate_shipping_charges
    promotions = Promotion.brand.shipping_charge.active.unexpired.joins(:brand_promotions).where(
      'brand_promotions.brand_id IN (?)', shopoth_line_items.map(&:brand_id).compact
    ).distinct

    return Configuration.shipping_charges unless promotions.size.positive?

    rules = promotions.map(&:promotion_rules).flatten
    home_delivery = rules.select { |rule| rule[:name] == 'home_delivery_charge' }.pluck(:value).min
    pick_up_point = rules.select { |rule| rule[:name] == 'pick_up_point_charge' }.pluck(:value).min
    express_delivery = rules.select { |rule| rule[:name] == 'express_delivery_charge' }.pluck(:value).min
    {
      pick_up_point: pick_up_point.to_i,
      home_delivery: home_delivery.to_i,
      express_delivery: express_delivery.to_i,
    }
  end

  def destroy_with_shopoth_line_items
    shopoth_line_items.each do |item|
      item.customer_order.present? ? item.update(cart_id: nil) : item.destroy
    end
    destroy!
  end

  def validate_cart_items_price(warehouse_id, business_type = 'b2c')
    errors = []
    shopoth_line_items.includes(:variant).where(sample_for: nil).each do |item|
      sku_discount = Discounts::SkuPromotions.call(variant: item.variant, quantity: item.quantity, cart: self,
                                                   line_item: item, warehouse_id: warehouse_id, business_type: business_type)
      next unless sku_discount[:applicable] == false && sku_discount[:error].present?

      errors.push("#{item.variant&.product} due to #{sku_discount[:error]}")
    end
    errors
  end

  def products_visible?
    shopoth_line_items.map do |item|
      if item.variant.product.present?
        true
      else
        false
      end
    end
  end

  def check_products_max_limit
    shopoth_line_items.map do |item|
      product = item.variant.product
      if product.max_quantity_per_order.present?
        shopoth_line_items.where(variant_id: product.variants.ids).sum(:quantity) <= product.max_quantity_per_order.to_i
      else
        true
      end
    end
  end

  def cart_promotions_create_update(promotions)
    existing_promotion = cart_promotions.where.not(promotion_id: promotions)
    existing_promotion.destroy_all if existing_promotion.present?
    return if promotions.empty?

    reload
    promotions.each { |p| cart_promotions.find_or_create_by!(promotion_id: p) }
  end

  def self.associate_user_with_cart(cart_id, warehouse, user, member_domain)
    cart = Cart.find_by(id: cart_id)
    user_current_cart = user.cart
    if cart.present? && user_current_cart.nil?
      cart.link_with_user(warehouse, member_domain, user)
    elsif cart.present? && user_current_cart.present?
      user_current_cart.merge_all_items(cart, member_domain, warehouse, user)
    end
  end

  def link_with_user(warehouse, member_domain, user)
    validate_cart_items_price(warehouse)
    update_cart_attr(member_domain, warehouse, user)
  end

  def merge_all_items(cart, member_domain, warehouse, user)
    return if cart == self

    cart.shopoth_line_items.each do |item|
      add_cart(item.variant, item.quantity, warehouse&.id)
    end
    update_cart_attr(member_domain, warehouse, user)
    cart.shopoth_line_items.delete_all
    cart.destroy!
  end

  private

  def cart_discount_update(user_domain = '', warehouse, coupon, current_user)
    if coupon&.promo_coupon.present?
      coupon.promo_coupon.apply_discount(self, coupon, current_user)
    else
      discount_context = Discounts::DiscountCalculation.call(cart: self,
                                                             member: user_domain,
                                                             coupon: coupon,
                                                             warehouse: warehouse,
                                                             user: current_user)

      all_discount = discount_context.total_discount
      update!(sub_total: shopoth_line_item_total.to_f,
              cart_discount: all_discount[:discount],
              coupon_code: all_discount[:coupon_code],
              cart_dis_type: all_discount[:dis_type],
              user: current_user)
      cart_promotions_create_update(all_discount[:promotion])
    end
  end
end
