# frozen_string_literal: true

module ShopothDistributor
  module V1
    class Dashboard < ShopothDistributor::Base
      resource :dashboard do
        desc 'Get Dashboard details for DH panel.'
        params do
          optional :start_date_time, type: DateTime
          optional :end_date_time, type: DateTime
        end
        get do
          start_time = params[:start_date_time].present? ? params[:start_date_time].to_datetime.utc.beginning_of_day : Time.now.beginning_of_month
          end_time = params[:end_date_time].present? ? params[:end_date_time].to_datetime.utc.end_of_day : Time.now.end_of_month

          unless start_time < end_time && (end_time - start_time) <= (3.month + 1.day)
            error!(failure_response_with_json('The selected date range is not valid! Please select a range within 3 months.',
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          completed_status_ids = OrderStatus.fetch_statuses(%w(completed partially_returned returned_from_customer)).pluck(:id)

          orders_with_date_filler = @current_distributor.customer_orders.
                                    where(order_status_id: completed_status_ids).
                                    where(completed_at: start_time..end_time)

          cash_collected_by_sr = 0
          collectable_cash_from_market = 0
          collected_by_rider = 0
          cash_collected_by_dh = 0
          orders_with_date_filler.includes(:payments).each do |co|
            collected_by_sr = co.payments.find_by(paymentable_type: %w(Partner),
                                                  receiver_type: %w(Route),)
            collected_by_dh = co.payments.find_by(paymentable_type: %w(Route Rider),
                                                  receiver_type: %w(Staff),)
            collectable_from_market = co.payments.find_by(paymentable_type: %w(User),
                                                          receiver_type: %w(Partner),)
            collected_by_rider += co.payments.find_by(paymentable_type: %w(User), receiver_type: %w(Rider))&.currency_amount || 0

            if collected_by_sr.present?
              cash_collected_by_sr += collected_by_sr.currency_amount || 0
            elsif collected_by_dh.present?
              cash_collected_by_dh += collected_by_dh.currency_amount || 0
            else
              collectable_cash_from_market += collectable_from_market&.currency_amount || 0
            end
          end
          cash_deposit_to_shopoth = orders_with_date_filler.joins(:aggregated_transaction_customer_orders).
            where(aggregated_transaction_customer_orders: { transaction_type: :customer_payment }).sum(:amount)
          partner_margin = orders_with_date_filler.joins(:partner_margin).sum(:margin_amount)
          dist_margin = orders_with_date_filler.joins(:distributor_margin).sum(:amount)
          campaign_names = Promotion.flash_sale.active.where(
            'to_date IN (?) OR (from_date <= ? AND to_date > ?)',
            start_time.to_date..end_time.to_date, end_time.to_date, end_time.to_date
          ).pluck(:title).compact

          online_orders_value = orders_with_date_filler.where.not(pay_type: CustomerOrder.pay_types[:cash_on_delivery])&.sum(:total_price) || 0

          response = {
            total_completed_order: orders_with_date_filler.size,
            total_completed_online_orders_value: online_orders_value,
            total_completed_order_value: orders_with_date_filler.sum(:total_price),
            collectable_cash_from_market: collectable_cash_from_market,
            cash_collected_by_sr: cash_collected_by_sr + cash_collected_by_dh + collected_by_rider - cash_deposit_to_shopoth,
            cash_deposit_to_shopoth: cash_deposit_to_shopoth,
            collected_by_rider: cash_collected_by_sr + collected_by_rider - cash_deposit_to_shopoth,
            dist_margin: dist_margin,
            partner_margin: partner_margin,
            campaign_names: campaign_names,
          }
          success_response_with_json('Successfully fetched dashboard details.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch dashboard details due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch dashboard details.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'customer order summary'
        params do
          use :pagination, per_page: 50
        end
        get '/order_summary' do
          orders = @current_distributor.customer_orders
          order_processing_at_cwh = orders.where(
            status: OrderStatus.fetch_statuses(%w(order_placed order_confirmed ready_to_ship_from_fc)),
          ).size
          in_transit_to_dh = orders.where(
            status: OrderStatus.getOrderStatus(OrderStatus.order_types[:in_transit_to_dh]),
          ).size
          delivery_pending = orders.where(
            status: OrderStatus.getOrderStatus(OrderStatus.order_types[:ready_to_shipment]),
          ).size
          in_transit_orders = orders.where(
            status: OrderStatus.fetch_statuses(%w(in_transit in_transit_partner_switch
                                                  in_transit_delivery_switch on_hold
                                                  in_transit_reschedule in_transit_cancelled)),
          )
          in_transit_orders_list = in_transit_orders.limit(10).order(id: :desc)
          in_transit_orders_list = paginate(
            Kaminari.paginate_array(
              ShopothDistributor::V1::Entities::CustomerOrder.represent(in_transit_orders_list)),
          )
          return_request = @current_distributor.return_customer_orders.
                           where(return_status: %w(initiated in_partner)).size
          return_collectable_by_sr = @current_distributor.return_customer_orders.
                                     where(return_status: %w(in_transit)).size
          response = {
            order_processing_at_cwh: order_processing_at_cwh,
            return_request: return_request,
            return_collectable_by_sr: return_collectable_by_sr,
            in_transit_to_dh: in_transit_to_dh,
            delivery_pending: delivery_pending,
            in_transit_orders_count: in_transit_orders.size,
            in_transit_orders: in_transit_orders_list,
          }
          success_response_with_json('Successfully fetched order summary.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch order summary due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch order summary.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])

        end
      end
    end
  end
end
