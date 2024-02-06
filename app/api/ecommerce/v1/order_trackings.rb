# frozen_string_literal: true

module Ecommerce
  module V1
    class OrderTrackings < Ecommerce::Base
      namespace :order_trackings do
        desc 'order list'
        params do
          use :pagination, per_page: 50
        end
        get do
          cus_orders = @current_user.customer_orders.includes(:status)
          cus_orders = cus_orders.where(id: params[:order_no].to_i) if params[:order_no].present?
          # TODO: Need to Optimize Query
          success_response_with_json(I18n.t('Ecom.success.messages.order_fetch_successful'),
                                     HTTP_CODE[:OK],
                                     Ecommerce::V1::Entities::OrderTracking.
                                       represent(paginate(Kaminari.paginate_array(cus_orders.order(id: :desc)))))
        rescue => error
          Rails.logger.info "tracking order list fetch failed #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.order_fetch_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY], {}), HTTP_CODE[:OK])
        end
      end
    end
  end
end
