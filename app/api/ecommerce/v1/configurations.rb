# frozen_string_literal: true

module Ecommerce
  module V1
    class Configurations < Ecommerce::Base
      resource :configurations do
        desc 'Get Ecom app version config.'
        route_setting :authentication, optional: true
        get '/app_config' do
          Configuration.return_app_version_config('ecom_app')
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nEcom app version config fetch failed due to: #{error.message}"
          error!(respond_with_json('Ecom app version config fetch failed.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end

