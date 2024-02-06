module OrderManagement
  class CreateCustomerOrder
    include Interactor

    delegate :customer,
             :cart,
             :order,
             :address,
             :shipping_type,
             :full_name,
             :phone,
             :new_address,
             :billing_address_id,
             :shipping,
             :order_status_id,
             :form_of_payment,
             :partner,
             :warehouse_id,
             :shipping_charge,
             :total_price,
             :order_type,
             :domain,
             :max_discount,
             :customer_orderable,
             :platform,
             :customer_device_id,
             :coupon,
             :tenure,
             :business_type,
             to: :context

    def call
      context.fail!(error: 'Cart can not be empty') if cart.shopoth_line_items.count.zero?

      if shipping_type != 'pick_up_point' && new_address.present?
        context.address = Address.new address_attributes
        context.fail!(error: address.errors.full_messages.to_sentence) unless address.save

        address.update!(addressable: customer) if new_address[:remember] == true
      end

      if shipping_type == 'express_delivery'
        unless Time.now.in_time_zone('Dhaka').hour.between?(10, 19)
          context.fail!(error: 'Sorry! Express Delivery is unavailable at the moment. For express delivery, you are requested to order between 10am and 8pm.')
        end
      end

      if form_of_payment == 'wallet_payment' && customer&.wallet&.currency_amount.to_i < cart.sub_total
        context.fail!(error: 'Insufficient amount in your wallet')
      end

      context.shipping_charge = fetch_shipping_charge
      context.max_discount = calculate_coupon_discount
      context.total_price = get_total_price.ceil

      context.order = CustomerOrder.new order_attributes
      if order.save!
        cart.destroy!
        WarehouseVariant.stock_update(order.shopoth_line_items, order.warehouse_id)
      else
        context.fail!(error: order.errors.full_messages.to_sentence)
      end
    end

    private

    def address_attributes
      {
        name: new_address[:full_name].strip,
        title: new_address[:title].strip,
        district_id: new_address[:district_id],
        thana_id: new_address[:thana_id],
        area_id: new_address[:area_id],
        address_line: new_address[:home_address],
        phone: new_address[:phone],
        zip_code: new_address[:post_code],
        alternative_phone: new_address[:alternative_phone],
      }
    end

    def order_attributes
      order_attributes = {
        customer: customer,
        cart_total_price: cart.shopoth_line_item_total,
        billing_address: shipping_address,
        shipping_address: shipping_address,
        shipping_type: shipping_type,
        pay_type: form_of_payment,
        warehouse_id: warehouse_id,
        partner: partner,
        shipping_charge: shipping_charge,
        total_price: total_price,
        total_discount_amount: total_discount_calculation.ceil,
        name: name,
        phone: order_phone,
        item_count: cart.total_items,
        order_type: order_type,
        promotion_ids: max_discount[:promotion],
        coupon_code: max_discount[:coupon_code],
        customer_orderable: customer_orderable,
        cart: cart,
        return_coupon: max_discount[:returned],
        coupon_discount: max_discount[:discount],
        vat_shipping_charge: vat_charge_on_shipping,
        tenure: (tenure if form_of_payment == 'emi_payment'),
      }
      order_attributes[:platform] = platform if platform.present?
      order_attributes[:customer_device_id] = customer_device_id if customer_device_id.present?
      order_attributes[:business_type] = business_type if business_type.present?
      order_attributes
    end

    def calculate_coupon_discount
      w = Warehouse.find_by(id: warehouse_id)
      if coupon&.promo_coupon.present?
        promo_coupon_discount_calculation(w)
      else
        Coupon.calculate_coupon(coupon, cart, domain, w, customer)
      end
    end

    def promo_coupon_discount_calculation(warehouse)
      locations = if shipping_type == 'pick_up_point'
                    { district: partner.address&.district, thana: partner.address&.thana, area: partner.address&.area }
                  else
                    { district: shipping&.district, thana: shipping&.thana, area: shipping&.area }
                  end
      locations[:warehouse] = warehouse
      locations[:partner] = partner
      promo_coupon = coupon.promo_coupon
      context.fail!(error: I18n.t('Ecom.errors.messages.coupon_not_running')) unless promo_coupon&.running?

      applicable = promo_coupon.applicable?(cart, customer, order_type, locations)
      context.fail!(error: I18n.t('Ecom.errors.messages.coupon_not_applicable')) unless applicable

      discount = promo_coupon.discount_calculation(cart)
      # TODO: Implement max discount between coupon and member discount.
      Coupon.coupon_discount_params(coupon.code, discount.ceil, false, nil, 'promo_coupon')
    end

    def billing_address
      billing = Address.find_by(id: billing_address_id)
      billing || address
    end

    def shipping_address
      shipping || address
    end

    def name
      # Should change from partner app to send full_name as first_name & last_name removed in new requirements
      if shipping_type == 'pick_up_point'
        full_name&.strip
      else
        new_address.present? ? new_address[:full_name].strip : shipping.name
      end
    end

    def order_phone
      if shipping_type == 'pick_up_point'
        phone
      else
        new_address.present? ? new_address[:phone] : shipping.phone
      end
    end

    def get_total_price
      sub_total = if max_discount[:dis_type] == 'abs'
                    sub_total_for_abs_discount
                  else
                    cart.shopoth_line_item_total
                  end
      grand_total = sub_total <= max_discount[:discount] ? 0 : sub_total - max_discount[:discount]
      max_discount[:dis_type] == 'abs' ? grand_total : grand_total + shipping_charge + vat_charge_on_shipping
    end

    def sub_total_for_abs_discount
      cart.shopoth_line_item_total + shipping_charge + vat_charge_on_shipping
    end

    def total_discount_calculation
      return max_discount[:discount] unless max_discount[:dis_type].present?

      max_discount[:discount] > sub_total_for_abs_discount ? sub_total_for_abs_discount : max_discount[:discount]
    end

    def fetch_shipping_charge
      cart.calculate_shipping_charges[shipping_type.to_sym]
    end

    def vat_charge_on_shipping
      (shipping_charge * 0.15).round
    end
  end
end
