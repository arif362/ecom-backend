# frozen_string_literal: true

module ShopothDistributor
  module V1
    class OrderStatuses < ShopothDistributor::Base
      namespace :order_status do
        desc 'Order Status list'
        get '/admin' do
          order_statuses = OrderStatus.where.not(admin_order_status: nil)
          success_response_with_json('Successfully fetched order status list',
                                     HTTP_CODE[:OK], order_statuses)
        rescue StandardError => error
          Rails.logger.info "Unable to fetch order statuses due to, -#{error.message}"
          error!(failure_response_with_json('Unable to order status list',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])

        end
      end
    end
  end
end
