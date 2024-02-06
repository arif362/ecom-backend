module ShopothWarehouse
  module V1
    class Dashboard < ShopothWarehouse::Base
      helpers ShopothWarehouse::V1::Helpers::StatHelper

      helpers do
        def seven_days
          1.week.ago.in_time_zone('Asia/Dhaka').to_date
        end

        def fetch_all_orders
          if check_dh_warehouse
            @current_staff.warehouse.customer_orders.orders_date_range(seven_days).order(created_at: :asc)
          else
            CustomerOrder.orders_date_range(seven_days).order(created_at: :asc)
          end
        end

        def fetch_dates
          today = Time.now.in_time_zone('Asia/Dhaka').to_date
          ((6.day.ago.in_time_zone('Asia/Dhaka').to_date)..today).map { |date| date.strftime('%d-%m-%Y') }
        end

        def fetch_completed_orders
          if check_dh_warehouse
            @current_staff.warehouse.customer_orders.joins(customer_order_status_changes: :order_status).
              where('order_statuses.order_type IN (6,7) AND
                    customer_order_status_changes.created_at >= ?', seven_days).
              order('customer_order_status_changes.created_at ASC').uniq
          else
            CustomerOrder.all.joins(customer_order_status_changes: :order_status).
              where('order_statuses.order_type IN (6,7) AND
                     customer_order_status_changes.created_at >= ?', seven_days).
              order('customer_order_status_changes.created_at ASC').uniq
          end
        end
      end

      namespace :dashboard do
        desc 'Last 7 days order'
        get '/stats/7/days' do
          all_orders ||= fetch_all_orders
          dates ||= fetch_dates
          {
            order_type: stat_based_on_order_type(all_orders, dates),
            shipping_type: stat_based_on_shipping_type(fetch_completed_orders, dates),
            value_discount: value_discount(all_orders, dates),
            cart_mrp: cart_mrp(all_orders, dates),
            top_10_skus: top_10_sku(all_orders),
            avg_basket: avg_basket_value(all_orders, dates),
          }
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
