module Ecommerce
  module V1
    class AreaSearch < Ecommerce::Base
      namespace :areas do
        desc 'Get all area based on thana_id.'
        params do
          requires :thana_id, type: Integer
          optional :pick_up_point, type: Boolean
        end
        route_setting :authentication, optional: true
        get do
          areas = if params[:pick_up_point]
                    partner_ids = Partner.active.joins(:address).
                      where(addresses: { thana_id: params[:thana_id] }).ids
                    area_ids = Address.where(addressable_type: 'Partner', addressable_id: partner_ids).
                      pluck(:area_id).uniq
                    Area.where(id: area_ids)
                  else
                    Area.home_delivery_by_thana(params[:thana_id])
                  end

          response = Ecommerce::V1::Entities::AreasSearch.represent(areas)
          success_response_with_json('Successfully fetched area list.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch area list due to: #{error.message}"
          return { success: false, status: HTTP_CODE[:UNPROCESSABLE_ENTITY], message: 'Unable to fetch area list.', data: [] }
        end
      end
    end
  end
end
