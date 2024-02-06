module Ecommerce
  module V1
    class PickDistrict < Ecommerce::Base
      namespace 'select' do
        desc 'Get all Districts.'
        route_setting :authentication, optional: true
        get '/districts' do
          success_response_with_json('Successfully fetched all districts.', HTTP_CODE[:OK],
                                     Ecommerce::V1::Entities::Districts.represent(District.fetch_warehouse))
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch districts due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch districts.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:OK])
        end

        desc 'Get warehouse id'
        route_setting :authentication, optional: true
        get '/district/:id/warehouse' do
          warehouse_ids = Warehouse.where(warehouse_type: 'distribution', public_visibility: true).
                          joins(address: :district).where("districts.id = ?",
                                                          params[:id]).pluck(:id)
          if warehouse_ids.empty?
            { message: 'Sorry no warehouse found' }
          else
            { warehouse_ids: warehouse_ids }
          end
        rescue => err
          error!("Unable to process request #{err}", HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end