# frozen_string_literal: true

module Ecommerce
  module V1
    class PromoBanners < Ecommerce::Base
      resources :promo_banners do
        desc 'Get visible promo_banners for ecommerce.'
        route_setting :authentication, optional: true
        get do
          data = Ecommerce::V1::Entities::PromoBanners.represent(PromoBanner.find_by(is_visible: true))
          success_response_with_json('Successfully fetched promo_banners.', HTTP_CODE[:OK], data)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch promo banners due to: #{error.message}"
          error!(failure_response_with_json('Unable to fetch promo banners.',
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
