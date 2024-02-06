# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class OrderStatuses < ShopothWarehouse::Base
      namespace :order_status do
        desc 'Show All Order Status'
        get '/admin' do
          OrderStatus.where.not(admin_order_status: nil)
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
