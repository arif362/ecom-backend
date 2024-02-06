module ShopothWarehouse
  module V1
    module Entities
      class RoutePartner < Grape::Entity
        expose :id
        expose :name
        expose :phone
        expose :order_count do |partner, _options|
          _options[:order_count]
        end
        expose :margin_amount do |partner, _options|
          _options[:partner_margin]
        end
        expose :margin_received_by_partner

        def margin_received_by_partner
          aggregated_payment = object&.aggregated_payments&.partner_margin&.where(month: options[:month], year: options[:year]).first
          aggregated_payment&.payment&.successful?.present?
        end
      end
    end
  end
end
