module PartnerOrder
  class CreatePartnerOrder
    include Interactor

    delegate :customer,
             :cart,
             :order,
             :address,
             :shipping_type,
             :new_address,
             :billing_address_id,
             :shipping_address_id,
             :order_status_id,
             :form_of_payment,
             :partner,
             :rider,
             :warehouse_id,
             :shipping_charge,
             :total_price,
             :user_promotion,
             :order_type,
             :commission,
             :warehouse_variant,
             :discount_for_loyal_customer,
             :check_available_quantity,
             to: :context

    def call
      if shipping_type == 'pick_up_point' && new_address.present?
        context.address = Address.new address_attributes
        context.fail!(error: address.errors.full_messages.to_sentence) unless address.save
      end

      if shipping_type == 'express_delivery'
        unless (10..20) === DateTime.now.utc.hour + 6
          context.fail!(error: "Sorry! Express Delivery is unavailable at the moment. For express delivery, you are requested to order between 10am and 8pm.")
        end
      end

      if form_of_payment == 'wallet_payment'
        unless customer&.wallet&.currency_amount
          return context.fail!(error: 'Insufficient amount in your wallet')
        end

        if customer&.wallet&.currency_amount < cart.sub_total
          context.fail!(error: 'Insufficient amount in your wallet')
        end
      end
      context.warehouse_id = get_warehouse_id
      context.check_available_quantity = available_quantity?
      context.discount_for_loyal_customer = 0
      context.total_price = get_total_price
      context.order = CustomerOrder.new order_attributes
      if order.save
        send_push_to_partner if order.order_type == 'organic' && partner.present?

        message = "Successfully order placed. Order ID is #{order.frontend_id}, Order PIN is #{order.pin}. Please share this PIN when receive the order."
        # SmsManagement::SendMessage.call(phone: order&.customer&.phone, message: message)
        context.warehouse_variant = warehouse_variant_update
      else
        context.fail!(error: order.errors.full_messages.to_sentence)
      end
    end

    private

    def address_attributes
      {
        name: "#{new_address[:name]}",
        district_id: new_address[:district_id],
        thana_id: new_address[:thana_id],
        area_id: new_address[:area_id],
        address_line: new_address[:home_address],
        phone: new_address[:phone],
        zip_code: new_address[:post_code],
        alternative_phone: new_address[:alternative_phone],
        # addressable_id: customer.id,
        # addressable_type: 'User',
      }
    end

    def order_attributes
      {
        customer: customer,
        shopoth_line_items: cart.shopoth_line_items,
        cart_total_price: cart.shopoth_line_item_total,
        # status_attributes: order_status_attributes,
        billing_address: billing_address,
        shipping_address: shipping_address,
        shipping_type: shipping_type,
        pay_type: form_of_payment,
        warehouse_id: context.warehouse_id,
        partner: partner,
        rider: rider,
        shipping_charge: shipping_charge,
        total_price: total_price,
        total_discount_amount: discount_for_loyal_customer,
        name: "#{new_address[:name]}",
        phone: new_address[:phone],
        item_count: cart.total_items,
        order_type: order_type,
        partner_commission: commission || 0,
      }
    end

    def user_promotion_attributes
      {
        user: customer,
        discount_amount: cart.cart_discount,
        customer_order: order,
        used: true,
      }
    end

    def billing_address
      billing = Address.find_by(id: billing_address_id)
      billing || address
    end

    def shipping_address
      shipping = Address.find_by(id: shipping_address_id)
      shipping || address
    end

    def get_warehouse_id
      if shipping_type == 'pick_up_point'
        partner.route.warehouse_id
      else
        District.find_by_id(address.district_id)&.warehouse&.id
      end
    end

    def get_total_price
      shipping_charge + cart.sub_total - discount_for_loyal_customer
    end

    # def loyal_customer_discount
    #   return unless customer.is_loyal?
    #
    #   cart.sub_total * 0.05
    # end

    def send_push_to_partner
      app_notification = AppNotification.order_delivery_notification(order)
      PushNotification::CreateAppNotifications.call(
        app_user: partner,
        title: app_notification[:title],
        message: app_notification[:message])
    end

    def warehouse_variant_update
      context.order.shopoth_line_items.each do |line_item|
        warehouse_variant = WarehouseVariant.find_by(variant_id: line_item.variant.id, warehouse_id: warehouse_id)
        warehouse_variant.available_quantity -= line_item.quantity
        warehouse_variant.booked_quantity += line_item.quantity
        warehouse_variant.save!
      end
    end

    def available_quantity?
      cart.shopoth_line_items.each do |line_item|
        warehouse_variant = WarehouseVariant.find_by(variant_id: line_item.variant.id, warehouse_id: warehouse_id)
        if line_item.quantity > warehouse_variant.available_quantity
          context.fail!(error: "Can not create order due to unavailable quantity for product #{line_item.variant.product.title}")
        end
      end
    end
  end
end
