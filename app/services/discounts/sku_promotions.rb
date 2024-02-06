module Discounts
  class SkuPromotions
    include Interactor

    delegate :variant,
             :cart,
             :quantity,
             :discount_amount,
             :discounts,
             :max_discount,
             :line_item,
             :result,
             :warehouse_id,
             :get_y,
             :buy_x,
             :flash_discount,
             :business_type,
             to: :context

    def call
      context.discounts = []
      context.result = {}
      context.get_y = {}
      context.buy_x = {}
      context.flash_discount = 0
      promotion_calculation
      variant_discount_calculation
      context.max_discount = process_maximum_discount
      create_or_update_line_items
    end

    private

    def is_b2b?
      context.business_type == 'b2b'
    end

    def variant_price(_variant=nil)
      _variant = _variant.present? ?  _variant : context.variant
      is_b2b? ? _variant&.b2b_price : _variant&.price_consumer
    end

    def variant_effective_mrp
      is_b2b? ? variant&.b2b_effective_mrp : variant&.effective_mrp
    end

    def promotion_calculation
      promotions = variant.promotions.active.unexpired.distinct
      unless promotions.present?
        return context.discounts.
               push({ discount: 0,
                      qty: quantity,
                      mrp: variant_price,
                      promotion: nil,
                      applicable: true,
                      error: '',
                      sample_for: nil, })
      end

      promotions.each do |promo|
        case promo.promotion_category
        when 'sku'
          calculate_sku_promo(promo, quantity)
        when 'flash_sale'
          next unless promo.running?

          calculate_flash_sale_promo(promo, quantity)
        else
          ''
        end
      end
    end

    def calculate_flash_sale_promo(promo, quantity)
      discount_amount = promo.promotion_variants.where(variant_id: variant.id).
                        maximum('promotion_variants.promotional_discount') || 0
      context.flash_discount = discount_amount > flash_discount ? discount_amount : flash_discount
      mrp = (variant_price - flash_discount).negative? ? 0 : (variant_price - flash_discount).ceil
      context.discounts.push({ discount: flash_discount, qty: quantity, promotion: promo.id,
                               mrp: mrp, sample_for: nil,
                               applicable: true, error: '', })
    end

    def calculate_sku_promo(promo, quantity)
      case promo.rule
      when 'percentage_of_discount'
        max_promo_qty = promo.value_for('max_per_order')
        discount_rate = promo.value_for('percent')
        max_amount = promo.value_for('max_amount')
        discount_amount = (variant_price * discount_rate) / 100
        discount_amount = discount_amount >= max_amount ? max_amount : discount_amount
        promo_discount = validate_quantity(max_promo_qty, quantity)
        unless promo_discount[:applicable]
          return context.discounts.push({ discount: discount_amount, qty: quantity, promotion: promo.id,
                                          mrp: variant_price, sample_for: nil,
                                          applicable: promo_discount[:applicable], error: promo_discount[:error], })
        end
        context.discounts.push({ discount: discount_amount, qty: quantity,
                                 mrp: variant_price - discount_amount,
                                 sample_for: nil,
                                 promotion: promo.id, applicable: true, error: '', })
      when 'absolute_amount_discount'
        max_promo_qty = promo.value_for('max_per_order')
        discount_amount = promo.value_for('amount')
        discount_amount = (variant_price - discount_amount).negative ? 0 : variant_price - discount_amount
        promo_discount = validate_quantity(max_promo_qty, quantity)
        unless promo_discount[:applicable]
          context.discounts.push({ discount: discount_amount, qty: quantity, promotion: promo.id,
                                   mrp: variant_price,
                                   sample_for: nil,
                                   applicable: promo_discount[:applicable], error: promo_discount[:error], })
        end
        context.discounts.push({ discount: discount_amount, qty: quantity,
                                 sample_for: nil, mrp: variant_price - discount_amount,
                                 promotion: promo.id, applicable: true, error: '', })
      when 'buy_x_get_y'
        variant_promo = promo.promotion_variants.where(state: 'buy', variant_id: variant.id).last
        sample_variant = promo.promotion_variants.where(state: 'get').last.variant
        return unless variant_promo.present? && sample_variant.present?

        x_qty = promo.value_for('x_qty')
        y_qty = promo.value_for('y_qty')
        if quantity < x_qty
          return context.discounts.push({ discount: 0, qty: quantity, promotion: nil,
                                          sample_for: nil, mrp: variant_price,
                                          applicable: true, error: '', })
        end
        sampleable_qty = (quantity / x_qty).floor
        y_qty = sampleable_qty * y_qty
        validate_sample_variant_stock(y_qty, sample_variant, promo)
      else
        context.discounts.push({ discount: 0, qty: quantity, promotion: nil,
                                 sample_for: nil, mrp: variant_price,
                                 applicable: true, error: '', })
      end
    end

    def variant_discount_calculation
      context.discounts.push({ discount: variant_price - variant_effective_mrp, qty: quantity, promotion: nil,
                               sample_for: nil, mrp: variant_effective_mrp,
                               applicable: true, error: '', })
    end

    def validate_quantity(max_promo_qty, quantity)
      if quantity <= max_promo_qty
        { applicable: true, error: '' }
      else
        { applicable: false, error: "You can not buy more than #{max_promo_qty.to_i}" }
      end
    end

    def validate_sample_variant_stock(y_qty, sample_variant, promo)
      existing_qty = cart.shopoth_line_items.where(sample_for: nil).
                     where(variant_id: sample_variant.id).sum(&:quantity)
      available_quantity = WarehouseVariant.
                           find_by(variant_id: sample_variant.id, warehouse_id: warehouse_id)&.
                           available_quantity || 0
      return if available_quantity < y_qty + existing_qty

      insert_buyx_gety(y_qty, sample_variant, promo)
    end

    def insert_buyx_gety(y_qty, sample_variant, promo)
      context.buy_x = { discount: variant_price - variant_effective_mrp, qty: quantity, promotion: promo.id,
                        sample_for: nil, mrp: variant_effective_mrp,
                        applicable: true, error: '', }
      context.get_y = { discount: variant_price(sample_variant), qty: y_qty, promotion: promo.id,
                        sample_for: '', mrp: variant_price(sample_variant),
                        applicable: true, error: '', sample: sample_variant, }
    end

    def delete_sample_items(line_item)
      line_item.samples.delete_all if line_item.samples.present? && get_y.empty?
    end

    def process_maximum_discount
      if buy_x.present? && get_y.present?
        buy_x
      else
        context.discounts.max_by { |d| d[:discount] }
      end
    end

    def create_or_update_line_items
      # TODO: Refactor update and create line item, usable both for line items and its sample
      if max_discount[:error].present? && max_discount[:applicable] == false
        return context.result = { success: false, error: max_discount[:error] }
      end

      line_item = context.line_item.present? ? update_line_item : create_line_item
      delete_sample_items(line_item)
      if get_y.present?
        get_y[:sample_for] = line_item.id
        create_update_sample_line_item(get_y, line_item)
      end
      context.result = { success: true, error: '', line_item: line_item }
    end

    def update_line_item
      line_item.update!(quantity: max_discount[:qty],
                        price: variant_price,
                        sub_total: max_discount[:mrp] * max_discount[:qty],
                        discount_amount: max_discount[:discount] * max_discount[:qty],
                        promotion_id: max_discount[:promotion])
      line_item
    end

    def create_line_item
      cart.shopoth_line_items.create!(variant: variant,
                                      quantity: max_discount[:qty],
                                      price: variant_price,
                                      sub_total: max_discount[:mrp] * max_discount[:qty],
                                      discount_amount: max_discount[:discount] * max_discount[:qty],
                                      promotion_id: max_discount[:promotion])
    end

    def create_update_sample_line_item(get_y, line_item)
      sample_item = cart.shopoth_line_items.find_by(variant_id: get_y[:sample].id, sample_for: line_item.id)
      if sample_item.present?
        sample_item.update!(variant: get_y[:sample],
                            quantity: get_y[:qty],
                            price: get_y[:mrp],
                            sub_total: 0,
                            discount_amount: get_y[:mrp] * get_y[:qty],
                            promotion_id: get_y[:promotion],
                            sample_for: get_y[:sample_for])
      else
        sample_item = cart.shopoth_line_items.create!(variant: get_y[:sample],
                                                      quantity: get_y[:qty],
                                                      price: get_y[:mrp],
                                                      sub_total: 0,
                                                      discount_amount: get_y[:mrp] * get_y[:qty],
                                                      promotion_id: get_y[:promotion],
                                                      sample_for: get_y[:sample_for])
      end
      other_samples = line_item.samples.where.not(id: sample_item.id)
      other_samples.delete_all if other_samples.present?
    end
  end
end
