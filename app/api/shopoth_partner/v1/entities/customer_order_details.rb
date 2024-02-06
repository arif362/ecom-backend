module ShopothPartner
  module V1
    module Entities
      class CustomerOrderDetails < Grape::Entity
        expose :id, as: :order_id
        expose :created_at, as: :order_date
        expose :customer
        expose :order_type
        expose :order_status
        expose :shopoth_line_items, using: ShopothPartner::V1::Entities::OrdersLineItems
        expose :total_price
        expose :return_reasons
        expose :business_type

        def customer
          {
            name: object&.customer&.name,
            phone: object&.customer&.phone,
          }
        end

        def order_status
          object&.status&.order_type
        end

        def total_price
          retailer_prices = []
          consumer_prices = []
          partner_margins = []
          b2b_prices = []
          object&.shopoth_line_items&.each do |line_item|
            retailer_price = (line_item.variant.price_retailer.to_d * line_item.quantity.to_d).round(2)
            retailer_prices << retailer_price
            consumer_price = (line_item.variant.price_consumer.to_d * line_item.quantity.to_d).round(2)
            consumer_prices << consumer_price
            b2b_price = (line_item.variant.b2b_price.to_d * line_item.quantity.to_d).round(2)
            b2b_prices << b2b_price
            partner_margins << (consumer_price - retailer_price).abs
          end

          {
            retailer_price: retailer_prices.sum.ceil,
            b2b_price: b2b_prices.sum.ceil,
            consumer_price: consumer_prices.sum.ceil,
            partner_margin: partner_margins.sum.ceil,
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
