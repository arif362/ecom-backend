module Ecommerce
  module V1
    class ThanaSearch < Ecommerce::Base
      namespace :thanas do
        desc 'Get all thana based on district_id.'
        params do
          requires :district_id, type: Integer
          optional :pick_up_point, type: Boolean
        end
        route_setting :authentication, optional: true
        get do
          thanas = if params[:pick_up_point]
                     partner_ids = Partner.active.joins(:address).
                       where(addresses: { district_id: params[:district_id] }).ids
                     thana_ids = Address.where(addressable_type: 'Partner', addressable_id: partner_ids).
                       pluck(:thana_id).uniq
                     partner_ids = Partner.active.joins(:address).
                       where(addresses: { thana_id: [thana_ids] }).ids
                     area_ids = Address.where(addressable_type: 'Partner', addressable_id: partner_ids).
                       pluck(:area_id).uniq
                     Thana.where(id: thana_ids).joins(:areas).where(areas: { id: area_ids }).uniq
                   else
                     Thana.home_delivery_by_district(params[:district_id]).joins(:areas).
                       where(areas: { home_delivery: true }).uniq
                   end

          response = Ecommerce::V1::Entities::ThanasSearch.represent(thanas)
          success_response_with_json('Successfully fetched thana list.', HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch thana list due to: #{error.message}"
          return { success: false, status: HTTP_CODE[:UNPROCESSABLE_ENTITY], message: 'Unable to fetch thana list.', data: [] }
        end
      end
    end
  end
end
