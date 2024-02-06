module ShopothWarehouse
  module V1
    class RouteMargins < ShopothWarehouse::Base
      helpers do
        def partner_info(routes, params)
          start_date = DateTime.civil(params[:year], params[:month], 1).in_time_zone('Dhaka').beginning_of_day
          end_date = DateTime.civil(params[:year], params[:month], -1).in_time_zone('Dhaka').end_of_day
          completed_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:completed])
          partial_return_status = OrderStatus.getOrderStatus(OrderStatus.order_types[:partially_returned])
          output = []
          partners = Partner.where(route_id: routes.map(&:id))
          partners = partners.where(schedule: params[:partner_schedule]) if params[:partner_schedule].present?
          partners.each do |partner|
            customer_orders = partner.customer_orders.where(status: [completed_status, partial_return_status], completed_at: start_date..end_date)
            partner_customer_orders = customer_orders.select do |order|
              order.partner_margin.present?
            end

            partner_margin = partner_customer_orders.sum { |order| order&.partner_margin&.margin_amount }
            output << { id: partner.id,
                        name: partner.name,
                        phone: partner.phone,
                        order_count: partner_customer_orders.count,
                        margin_amount: partner_margin.round(2),
                        margin_received_by_partner: margin_received_by_partner(partner, params[:year], params[:month]),
                        route_title: partner.route.title,
                        sr_name: partner.route.sr_name,
                        distributor_name: partner.route&.distributor&.name,
                      }
          end
          output
        end

        def margin_received_by_partner(partner, month, year)
          aggregated_payment = partner&.aggregated_payments&.partner_margin&.where(month: month, year: year).first
          aggregated_payment&.payment&.successful?.present?
        end
      end
      resource :route_margins do
        desc 'SR details partner margin list.'
        params do
          requires :route_id, type: Integer
          requires :month, type: Integer
          requires :year, type: Integer
          requires :partner_schedule, type: String
        end

        get '/list' do
          route = @current_staff.warehouse.routes.find_by(id: params[:route_id])
          return respond_with_json('Route not found', HTTP_CODE[:UNPROCESSABLE_ENTITY]) unless route.present?

          ShopothWarehouse::V1::Entities::RouteMargin.represent(
            route, month: params[:month], year: params[:year], partner_schedule: params[:partner_schedule]
          )
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nFailed to fetch SR margin list due to: #{error.message}"
          error!(respond_with_json('Failed to fetch SR margin list.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        params do
          optional :title, type: String
          requires :distributor_id, type: Integer
          requires :month, type: Integer
          requires :year, type: Integer
          optional :partner_schedule, type: String
        end
        get '/partners_export' do
          distributor = Distributor.find(params[:distributor_id])
          unless distributor
            error!(respond_with_json('Distributor Not Found', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:OK])
          end
          routes = distributor.routes

          routes = params[:title].present? ? routes.where('LOWER(title) LIKE ?', "%#{params[:title].downcase}%") : routes

          partner_info(routes, params)

        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nFailed to fetch partner info list due to: #{error.message}"
          error!(respond_with_json('Failed to fetch partner info list.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'SR margin Pay.'
        params do
          requires :route_id, type: Integer
          requires :month, type: Integer
          requires :year, type: Integer
          requires :partner_schedule, type: String
        end

        post '/pay' do
          route = @current_staff.warehouse.routes.find_by(id: params[:route_id])
          return respond_with_json('Route not found.', HTTP_CODE[:NOT_FOUND]) unless route.present?

          fc_payments = AggregatedTransaction.sub_agent_commission.where(
            month: params[:month], year: params[:year],
          )
          payment_found = false
          fc_payments.each do |payment|
            if payment&.bank_transaction&.transactionable_to == @current_staff.warehouse
              payment_found = true
              break
            end
          end
          return respond_with_json('FC not paid yet for this month.', HTTP_CODE[:NOT_FOUND]) unless payment_found

          existing_payment =
            AggregatedPayment.sr_margin.where(month: params[:month],
                                              year: params[:year],
                                              partner_schedule: params[:partner_schedule],
                                              received_by: route)
          return respond_with_json('Payment already exists.', HTTP_CODE[:NOT_ACCEPTABLE]) if existing_payment.present?

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

            if total_amount.positive?
              Payment.create!(aggregated_payment: aggregated_payment,
                              currency_amount: total_amount,
                              currency_type: 'BDT',
                              status: :pending,
                              form_of_payment: :cash,
                              paymentable: @current_staff,
                              receiver: route)
              respond_with_json('Successfully paid.', HTTP_CODE[:OK])
            else
              aggregated_payment.destroy
              respond_with_json('Payment amount not positive.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end
        rescue => ex
          error!(respond_with_json("Failed to pay SR margin due to: #{ex.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
