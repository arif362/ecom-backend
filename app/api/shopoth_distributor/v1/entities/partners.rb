module ShopothDistributor
  module V1
    module Entities
      class Partners < Grape::Entity
        expose :id
        expose :name
        expose :phone
        expose :order_count
        expose :margin_amount
        expose :margin_received_by_partner
        expose :route_title
        expose :sr_name
        expose :distributor_name
        expose :region_name

        def order_count
          customer_orders.size
        end

        def margin_amount
          customer_orders.sum(:margin_amount).round(2)
        end

        def margin_received_by_partner
          object.aggregated_payments&.partner_margin&.find_by(month: options[:month], year: options[:year])&.payment&.successful.present?
        end

        def route_title
          route.title
        end

        def sr_name
          route.sr_name
        end

        def distributor_name
          options[:distributor].name
        end

        def customer_orders
          @customer_orders ||= object.customer_orders.where(status: options[:statuses], completed_at: options[:date_range]).joins(:partner_margin)
        end

        def route
          @route ||= object.route
        end

        def region_name
          object.region || ''
        end
      end
    end
  end
end
