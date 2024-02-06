module ShopothPartner
  module V1
    module Entities
      class LineItemProductDetails < Grape::Entity
        expose :order_id
        expose :order_date
        expose :customer
        expose :order_type
        expose :order_status
        expose :shopoth_line_items
        expose :total_price
        expose :return_reasons
        expose :business_type

        def order_id
          object&.customer_order&.id
        end

        def business_type
          object&.customer_order&.business_type
        end

        def order_date
          object&.customer_order&.created_at
        end

        def customer
          customer = object&.customer_order&.customer
          {
            name: customer&.name,
            phone: customer&.phone,
          }
        end

        def order_status
          object&.customer_order&.status&.order_type
        end

        def order_type
          object&.customer_order&.order_type
        end

        def shopoth_line_items
          [ShopothPartner::V1::Entities::OrdersLineItems.represent(object)]
        end

        def total_price
          retailer_price = (object.variant.price_retailer.to_d * object.quantity.to_d).round(2)
          consumer_price = (object.variant.price_consumer.to_d * object.quantity.to_d).round(2)
          b2b_price = (object.variant.b2b_price.to_d * object.quantity.to_d).round(2)
          partner_margins = (consumer_price - retailer_price).abs

          {
            retailer_price: retailer_price,
            consumer_price: consumer_price,
            b2b_price: b2b_price,
            partner_margin: partner_margins,
          }
        end

        def return_reasons
          reasons = []
          ReturnCustomerOrder.reasons.each do |key, value|
            key = ReturnCustomerOrder::MAP_BN_REASON[value] if I18n.locale == :bn
            reasons << { value: value, text: key }
          end
          reasons
        end
      end
    end
  end
end
