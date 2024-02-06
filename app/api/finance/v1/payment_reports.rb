# frozen_string_literal: true

module Finance
  module V1
    class PaymentReports < Finance::Base
      resource :payment_reports do
        desc 'Get order payment collection report for finance.'
        params do
          optional :skip_pagination, type: Boolean
          optional :start_date_time, type: DateTime
          optional :end_date_time, type: DateTime
          optional :warehouse_id, type: Integer
          optional :distributor_id, type: Integer
          use :pagination, per_page: 50
        end
        get '/report' do
          start_date_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.at_beginning_of_month : Time.now.at_beginning_of_month
          end_date_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.at_end_of_month : Time.now.at_end_of_month
          unless start_date_time < end_date_time && (end_date_time - start_date_time) <= 3.month + 1.day
            error!(respond_with_json("The selected date range (start_date: #{start_date_time} and end_date: #{end_date_time}) is not valid! Please select a  range within 3 months.",
                                     HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          completed_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
          orders = CustomerOrder.joins(:customer_order_status_changes).where(
            customer_order_status_changes: { order_status_id: completed_status.id, created_at: start_date_time..end_date_time },
          )

          orders = orders&.where(warehouse_id: params[:warehouse_id]) if params[:warehouse_id].present?
          orders = orders&.where(distributor_id: params[:distributor_id]) if params[:distributor_id].present?
          # TODO: Need to Optimize Query
          orders = if params[:skip_pagination]
                     orders.includes(:partner).order(created_at: :desc)
                   else
                     paginate(Kaminari.paginate_array(orders.includes(:partner).order(created_at: :desc)))
                   end

          Finance::V1::Entities::PaymentReports.represent(orders)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch payment collection report due to: #{error.message}"
          error!(respond_with_json('Unable to fetch payment collection report.',
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
