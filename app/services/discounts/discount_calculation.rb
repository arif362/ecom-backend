module Discounts
  class DiscountCalculation
    include Interactor

    delegate :promotion,
             :cart,
             :member,
             :discount_amount,
             :discounts,
             :brand_discount,
             :coupon,
             :max_discount,
             :total_discount,
             :warehouse,
             :shipping_charge,
             :vat_on_shipping,
             :user,
             to: :context

    def call
      context.discounts = []
      context.brand_discount = { discount_amount: 0, promotion: [] }
      promotion_calculation
      member_discount_calculation
      brand_discount_calculation
      context.max_discount = process_maximum_discount
      context.total_discount = process_total_discount
    end

    private

    def promotion_calculation
      unless coupon.present?
        return context.discounts.push({ discount: 0, promotion: nil, coupon_code: nil,
                                        applicable: true, type: 'promo', })
      end

      if coupon.promotion.present?
        discount = promo_discount
        if !discount[:applicable]
          context.discounts.push({ discount: 0, promotion: nil, coupon_code: nil, applicable: false,
                                   type: 'promo', })
        else
          context.discounts.push({ discount: discount[:amount],
                                   promotion: discount[:promotion].id,
                                   coupon_code: discount[:coupon_code],
                                   applicable: true, type: 'promo',
                                   dis_type: promo_discount[:dis_type], })
        end
      elsif coupon.return_customer_order_id.present? || coupon.aggregate_return_id.present?
        discount = voucher_discount
        context.discounts.push({ discount: discount, promotion: nil, coupon_code: coupon.code,
                                 applicable: true, type: 'voucher', dis_type: 'abs', })
      elsif coupon.first_registration? || coupon.acquisition?
        discount_amount = total_cart_percentage_discount
        context.discounts.push({ discount: discount_amount, promotion: nil, coupon_code: coupon.code,
                                 applicable: true, type: coupon.coupon_type.to_s, dis_type: 'abs', })
      elsif coupon.multi_user?
        # sku_coupon_flag = 0
        cart_line_item_ids = []
        # check category of coupon
        if coupon.coupon_category.present?
          # check cart items are in categorized list
          category_ids = coupon.coupon_category.category_ids.reject(&:empty?).map(&:to_i)
          cart.shopoth_line_items.each do |line_item|
            product_category_ids = line_item.variant.product.product_categories.map(&:category_id)
            # category_inclusion type check
            next if (product_category_ids & category_ids).present? && coupon.coupon_category.excluded?

            next if (product_category_ids & category_ids).blank? && coupon.coupon_category.included?

            # push discounted item ids
            cart_line_item_ids.push(line_item.id)
          end
        end
        # check sku of coupon
        if coupon.skus? && !coupon.not_applicable?
          skus = coupon.skus.split(',').map(&:strip)
          variant_ids = Variant.where(sku: skus).map(&:id)
          cart_line_item_ids = check_sku_inclusion_type(variant_ids, cart_line_item_ids) || []
        end
        discount_amount = if !coupon.skus? && coupon.coupon_category.blank?
                            total_cart_percentage_discount
                          else
                            discount_per_item_calculation(cart_line_item_ids)
                          end

        # coupon_code = if coupon.skus?
        #                 sku_coupon_flag.nonzero? ? coupon.code : nil
        #               else
        #                 coupon.code
        #               end
        context.discounts.push({ discount: discount_amount, promotion: nil, coupon_code: coupon.code,
                                 applicable: true, type: 'multi_user', dis_type: 'abs', })
      end
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def promo_discount
      unless coupon.promotion.is_active?
        return { applicable: false, discount: 0, promotion: nil, coupon_code: nil }
      end
      unless coupon.promotion.running?
        return { applicable: false, discount: 0, promotion: nil, coupon_code: nil }
      end

      cart_total = cart.shopoth_line_item_total || 0.0
      promotion = coupon.promotion
      if promotion.minimum_cart_value?
        min_cart_value = promotion.value_for('min_cart_value')
        if cart_total < min_cart_value
          return { applicable: false, discount: 0, promotion: nil, coupon_code: nil }
        end
      end

      case promotion.rule
      when 'percentage_of_discount'
        discount_rate = promotion.promotion_rules.find_by(name: 'percent').value
        max_amount = promotion.promotion_rules.find_by(name: 'max_amount').value
        discount_amount = (cart_total * discount_rate) / 100
        discount_amount = discount_amount >= max_amount ? max_amount : discount_amount
        { applicable: true, amount: discount_amount, promotion: coupon.promotion, coupon_code: coupon.code }
      when 'absolute_amount_discount'
        discount_amount = promotion.promotion_rules.find_by(name: 'amount').value
        { applicable: true, amount: discount_amount, promotion: coupon.promotion,
          coupon_code: coupon.code, dis_type: 'abs', }
      else
        { applicable: false, discount: 0, promotion: nil, coupon_code: nil }
      end
    end

    def voucher_discount
      coupon.discount_amount.ceil
    end

    def member_discount_calculation
      cart_sub_total = cart.shopoth_line_item_total || 0
      discount = if member.present?
                   return 0 if member.is_a?(Partner) && member.is_b2b?

                   discount_amount = (cart_sub_total * 0.05).ceil
                   discount_amount > 100 ? 100 : discount_amount
                 else
                   0
                 end
      context.discounts.push({ discount: discount, promotion: nil, coupon_code: nil, applicable: true, type: 'member' })
    end

    def brand_discount_calculation
      brands = collect_items_brand
      return if brands.empty?

      calculate_brand_discount(brands)
    end

    def collect_items_brand
      brands = []
      cart.shopoth_line_items.map do |item|
        brand_id = item.variant.product.present? ? item.variant.brand&.id : nil
        next if brand_id.nil?

        found = brands.detect { |x| x['id'] == brand_id }
        if found
          found['amount'] += item.sub_total
        else
          brands << { 'id' => brand_id,
                      'amount' => item.sub_total, }
        end
      end
      brands
    end

    def calculate_brand_discount(brands)
      brands.each do |brnd|
        p = Promotion.brand.active.unexpired.joins(:brands, :promotion_rules).
            where('brands.id = ?', brnd['id']).distinct.first
        next unless p.present?

        discount = calculate_brand_promotion(p, brnd['amount'])
        brand_discount[:discount_amount] += discount
        brand_discount[:promotion].push(p.id)
      end
      brand_discount
    end

    def calculate_brand_promotion(promo, amount)
      rule = promo.rule
      case rule
      when 'percentage_of_discount'
        discount_rate = promo.value_for('percent')
        max_amount = promo.value_for('max_amount')
        min_amount = promo.value_for('min_order_value')
        return 0 if amount < min_amount

        discount_amount = (amount * discount_rate) / 100
        discount_amount >= max_amount ? max_amount : discount_amount
      when 'absolute_amount_discount'
        min_amount = promo.value_for('min_order_value')
        discount_amount = promo.value_for('amount')
        amount < min_amount ? 0 : discount_amount
      else
        0
      end
    end

    def process_maximum_discount
      context.discounts.max_by { |d| d[:discount] }
    end

    def process_total_discount
      if max_discount[:type] == 'promo' && max_discount[:applicable] == false
        {
          discount: brand_discount[:discount_amount].ceil,
          promotion: brand_discount[:promotion],
          coupon_code: nil,
          dis_type: max_discount[:dis_type],
        }
      else
        {
          discount: (max_discount[:discount] + brand_discount[:discount_amount]).ceil,
          promotion: brand_discount[:promotion].push(max_discount[:promotion]).compact,
          coupon_code: max_discount[:coupon_code],
          dis_type: max_discount[:dis_type],
        }
      end
    end

    def total_cart_percentage_discount
      if coupon.percentage?
        max_check = (cart.sub_total * coupon.discount_amount) / 100
        max_check > coupon.max_limit ? coupon.max_limit : max_check
      else
        (cart.sub_total - coupon.discount_amount).positive? ? coupon.discount_amount : cart.sub_total
      end
    end

    def discount_per_item_calculation(line_item_ids)
      discount_amount = 0
      line_item_ids.each do |line_item_id|
        line_item = cart.shopoth_line_items.find_by(id: line_item_id)
        line_item_price = line_item.effective_unit_price
        discount_amount += if coupon.percentage?
                             line_item_price * coupon.discount_amount / 100 * line_item.quantity
                           else
                             line_item_price
                           end
      end
      if coupon.percentage?
        discount_amount > coupon.max_limit ? coupon.max_limit : discount_amount
      else
        (discount_amount - coupon.discount_amount).positive? ? coupon.discount_amount : discount_amount
      end
    end

    def check_sku_inclusion_type(variant_ids, cart_line_item_ids)
      selected_ids = if coupon.coupon_category.present?
                       cart_line_item_ids
                     else
                       selected_variant_ids = if coupon.included?
                                                cart.shopoth_line_items.map(&:variant_id) & variant_ids
                                              elsif coupon.excluded?
                                                cart.shopoth_line_items.map(&:variant_id) - variant_ids
                                              end

                       return cart.shopoth_line_items.where(variant_id: selected_variant_ids).pluck(:id)
                     end
      cart.shopoth_line_items.each do |line_item|
        if variant_ids.include?(line_item.variant_id)
          if coupon.included? && !selected_ids.include?(line_item.id)
            # sku_coupon_flag = 1
            selected_ids.push(line_item.id)
          elsif coupon.excluded?
            selected_ids.delete(line_item.id)
          end
        end
      end

      selected_ids
    end
  end
end
