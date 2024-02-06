# frozen_string_literal: true

module Finance
  module V1
    class CustomerOrders < Finance::Base
      resource :customer_orders do
        # desc 'Customer order list for Distribution warehouse.'
        # get 'payment_received_by_fc' do
        #   start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_day
        #   end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_day : Time.now.at_end_of_day
        #   unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month
        #     return respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a range within 3 months.", HTTP_CODE[:NOT_ACCEPTABLE])
        #   end
        #
        #   date_range = start_date_time..end_date_time
        #
        #   customer_orders = CustomerOrder.joins(:payments).where("payments.paymentable_type = 'Route'
        #   AND payments.receiver_type = 'Staff'").where(payments: { created_at: date_range }).includes(:payments)
        #
        #   present customer_orders, with: Finance::V1::Entities::CustomerOrders
        # rescue StandardError => error
        #   Rails.logger.error "\n#{__FILE__}\nUnable to fetch customer order list due to: #{error.message}"
        #   error!(respond_with_json('Unable to fetch customer order list.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
        #          HTTP_CODE[:UNPROCESSABLE_ENTITY])
        # end

        route_param :id do
          desc 'get agent commission details with customer order'
          get 'agent_commission_details' do
            customer_order = CustomerOrder.find params[:id]

            if customer_order.present?
              present customer_order, with: Finance::V1::Entities::AgentCommission
            else
              status :not_found
              { status_code: :not_found, message: 'Customer order not found' }
            end
          rescue => ex
            error! respond_with_json("Unable to fetch customer order due to #{ex.message}",
                                     HTTP_CODE[:NOT_FOUND])
          end

          desc 'get Partner margin details with customer order'
          get 'partner_margin_details' do
            customer_order = CustomerOrder.find params[:id]

            if customer_order.present?
              present customer_order, with: Finance::V1::Entities::PartnerMargin
            else
              status :not_found
              { status_code: :not_found, message: 'Customer order not found' }
            end
          rescue => ex
            error! respond_with_json("Unable to fetch customer order due to #{ex.message}",
                                     HTTP_CODE[:NOT_FOUND])
          end
        end
      end
    end
  end
end
