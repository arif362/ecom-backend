# frozen_string_literal: true

module ShopothDistributor
  module V1
    class RouteMargin < ShopothDistributor::Base
      resource '/route_margins' do
        desc 'Export partner margins.'
        params do
          optional :title, type: String
          requires :month, type: Integer
          requires :year, type: Integer
          optional :partner_schedule, type: String
        end
        get '/partners_export' do
          start_date = DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
          end_date = DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day
          statuses = OrderStatus.fetch_statuses(%w(completed partially_returned))
          routes = params[:title].present? ? @current_distributor.routes.where('LOWER(title) LIKE ?', "%#{params[:title].downcase}%") : @current_distributor.routes
          partners = Partner.where(route_id: routes.ids)
          partners = partners.where(schedule: params[:partner_schedule]) if params[:partner_schedule].present?
          response = ShopothDistributor::V1::Entities::Partners.represent(
            partners, distributor: @current_distributor, month: params[:month], year: params[:year], date_range: start_date..end_date, statuses: statuses,
          )
          success_response_with_json('Successfully fetched partner info.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nFailed to fetch partner info list due to: #{error.message}"
          error!(respond_with_json('Failed to fetch partner info list.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'SR margin pay.'
        params do
          requires :route_id, type: Integer
          requires :month, type: Integer
          requires :year, type: Integer
          requires :partner_schedule, type: String
        end
        post '/pay' do
          route = @current_distributor.routes.find_by(id: params[:route_id])
          unless route
            error!(failure_response_with_json('Route not found.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          fc_payments = AggregatedTransaction.sub_agent_commission.where(
            month: params[:month], year: params[:year],
          )
          payment_found = false
          fc_payments.each do |payment|
            if payment&.bank_transaction&.transactionable_to == @current_distributor
              payment_found = true
              break
            end
          end

          unless payment_found
            error!(failure_response_with_json('FC not paid yet for this month.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end

          existing_payment =
            AggregatedPayment.sr_margin.where(month: params[:month],
                                              year: params[:year],
                                              partner_schedule: params[:partner_schedule],
                                              received_by: route)
          if existing_payment.present?
            error!(failure_response_with_json('Payment already exists.', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:OK])
          end

          ActiveRecord::Base.transaction do
            aggregated_payment =
              AggregatedPayment.sr_margin.create!(month: params[:month],
                                                  year: params[:year],
                                                  partner_schedule: params[:partner_schedule],
                                                  received_by: route)
            partners = route.partners.where(schedule: params[:partner_schedule])
            start_date = DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
            end_date = DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day

            total_amount = route.create_aggregated_SR_payment(aggregated_payment, partners, start_date, end_date)
            unless total_amount.positive?
              aggregated_payment.destroy
              error!(failure_response_with_json('Payment amount not positive.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                     HTTP_CODE[:OK])
            end

            Payment.create!(aggregated_payment: aggregated_payment,
                            currency_amount: total_amount,
                            currency_type: 'BDT',
                            status: :pending,
                            form_of_payment: :cash,
                            paymentable: @current_staff,
                            receiver: route)
            success_response_with_json('Successfully paid.', HTTP_CODE[:OK])
          end
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}Failed to pay SR margin due to: #{error.message}"
          error!(failure_response_with_json('Failed to pay SR margin.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
