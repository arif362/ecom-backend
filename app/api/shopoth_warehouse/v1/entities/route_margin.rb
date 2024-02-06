module ShopothWarehouse
  module V1
    module Entities
      class RouteMargin < Grape::Entity
        include ShopothWarehouse::V1::Helpers::Constants
        expose :id
        expose :title
        expose :phone
        expose :sr_name
        expose :distributor_name
        expose :sr_point
        expose :pay_status
        expose :partner_info

        def pay_status
          aggregated_payment = object&.aggregated_payments&.sr_margin&.find_by(month: options[:month], year: options[:year])
          if aggregated_payment&.payment&.successful?
            SR_MARGIN_PAYMENT_STATUS[:RECEIVED_BY_SR]
          elsif aggregated_payment&.payment.present?
            SR_MARGIN_PAYMENT_STATUS[:PAID_TO_SR]
          else
            SR_MARGIN_PAYMENT_STATUS[:PENDING]
          end
        end

        def partner_info
          start_date = DateTime.civil(options[:year], options[:month], 1).in_time_zone('Dhaka').beginning_of_day
          end_date = DateTime.civil(options[:year], options[:month], -1).in_time_zone('Dhaka').end_of_day
          completed_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
          partial_return_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:partially_returned])
          output = []
          total_margin = 0
          object.partners.each do |partner|
            customer_orders = partner.customer_orders.where(status: [completed_status, partial_return_status], completed_at: start_date..end_date)
            partner_customer_orders = customer_orders.select do |order|
              order.partner_margin.present?
            end

            partner_margin = partner_customer_orders.sum { |order| order&.partner_margin&.margin_amount }
            total_margin += partner_margin
            output << ShopothWarehouse::V1::Entities::RoutePartner.represent(partner, partner_margin: partner_margin.round(2), order_count: partner_customer_orders.count, month: options[:month], year: options[:year])
          end
          { total_payment: total_margin.round(2), details_list: output }
        end

        def distributor_name
          object&.distributor&.name
        end
      end
    end
  end
end
