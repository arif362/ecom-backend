# frozen_string_literal: true

module Finance
  module V1
    class PaymentHistories < Finance::Base
      resource :payment_histories do
        desc 'Get payment histories for Finance Admin.'
        params do
          optional :skip_pagination, type: Boolean
          optional :warehouse_id, type: Integer
          optional :distributor_id, type: Integer
          requires :start_month, type: Integer
          requires :end_month, type: Integer
          requires :start_year, type: Integer
          requires :end_year, type: Integer
          use :pagination, per_page: 50
        end
        get do
          payment_histories = MonthWisePaymentHistory.where(
            'month BETWEEN ? AND ?', "#{params[:start_year]}-#{params[:start_month].to_s.rjust(2, '0')}", "#{params[:end_year]}-#{params[:end_month].to_s.rjust(2, '0')}"
          )

          payment_histories = params[:warehouse_id].present? ? payment_histories.where(warehouse_id: params[:warehouse_id]) : payment_histories
          payment_histories = params[:distributor_id].present? ? payment_histories.where(distributor_id: params[:distributor_id]) : payment_histories
          unless payment_histories.present?
            error!(respond_with_json('Payment histories not found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

          if params[:skip_pagination]
            Finance::V1::Entities::PaymentHistories.represent(payment_histories)
          else
            # TODO: Need to Optimize Query
            data = Finance::V1::Entities::PaymentHistories.represent(
              paginate(Kaminari.paginate_array(payment_histories)),
            )
            {
              total_fc_collection: payment_histories&.sum(:fc_total_collection) || 0,
              total_collection: payment_histories&.sum(:total_collection) || 0,
              agent_commission: payment_histories&.sum(:agent_commission) || 0,
              total_fc_commission: payment_histories&.sum(:fc_commission) || 0,
              total_partner_commission: payment_histories&.sum(:partner_commission) || 0,
              payment_histories: data,
            }
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch payment history list due to: #{error.message}"
          error!(respond_with_json('Unable to fetch payment history list.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end
      end
    end
  end
end
