# frozen_string_literal: true

module ShopothCustomerCare
  module V1
    class OrderStatuses < ShopothCustomerCare::Base
      resource '/' do
        desc 'Show All Order Status'
        get '/order_statuses' do
          OrderStatus::order_types
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Show All Return Order Status'
        get '/return_statuses' do
          ReturnCustomerOrder::return_statuses
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

      end
    end
  end
end
