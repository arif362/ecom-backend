# frozen_string_literal: true

module Ecommerce
  module V1
    class Sliders < Ecommerce::Base
      resource :sliders do
        desc 'Get all slider filtered by image type.'
        route_setting :authentication, optional: true
        params do
          requires :image_type, type: String
        end
        get do
          unless Slide.img_types.include?(params[:image_type])
            error!(failure_response_with_json(I18n.t('Ecom.errors.messages.wrong_image_type'),
                                              HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end

          sliders = Slide.published.send(params[:image_type]).sample
          response = Ecommerce::V1::Entities::Sliders.represent(sliders)
          success_response_with_json(I18n.t('Ecom.success.messages.slider_fetch_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch sliders due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.slider_fetch_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
