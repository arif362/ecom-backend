# frozen_string_literal: true

module ShopothCustomerCare
  module V1
    class Partners < ShopothCustomerCare::Base
      helpers ShopothCustomerCare::V1::Serializers::CustomerOrderSerializer

      resource :partners do
        desc 'Return all partners'
        params do
          use :pagination, per_page: 50
        end
        get do
          partners = Partner.active.filter_by_address(params[:district_id], params[:thana_id], params[:area_id], params[:address_line])
          if partners.present?
            present paginate(Kaminari.paginate_array(partners)), with: ShopothCustomerCare::V1::Entities::Partners::List
          else
            status :not_found
            { success: false, message: 'Partners not found' }
          end
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Return partners by area_id filtering'
        get '/areas/:id' do
          partners = Partner.active.all
          partners = partners.joins(:address).where(addresses: { area_id: params[:id] })
          present partners.order(created_at: :desc), with: ShopothCustomerCare::V1::Entities::Partners::List
        rescue StandardError => error
          error!(error, HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Get partner'
        route_param :id do
          get do
            partner = Partner.find(params[:id])
            present partner, with: ShopothCustomerCare::V1::Entities::Partners::Details
          rescue => error
            error!("Unable to return details due to #{error.message}")
          end
        end

      end
    end
  end
end
