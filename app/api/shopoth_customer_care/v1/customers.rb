# frozen_string_literal: true

module ShopothCustomerCare
  module V1
    class Customers < ShopothCustomerCare::Base
      helpers ShopothCustomerCare::V1::Serializers::CustomerOrderSerializer

      resource :customers do
        desc 'Return list of all users as customers'
        params do
          use :pagination, per_page: 50
        end
        get do
          customers = User.all.order("id DESC")
          customers = customers.where(phone: params[:phone]) if params[:phone].present?
          present paginate(Kaminari.paginate_array(customers)), with: ShopothCustomerCare::V1::Entities::Customers::List
        rescue => ex
          error!("Unable to return customer list due to #{ex.message}")
        end

        desc 'Get customer details'
        route_param :id do
          get do
            user = User.find(params[:id])
            present user, with: ShopothCustomerCare::V1::Entities::Customers::Details
          rescue => error
            error!("Unable to return details due to #{error.message}")
          end
        end

      end
    end
  end
end
