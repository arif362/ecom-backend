# frozen_string_literal: true

module ThirdPartyService
  module Thanos
    class Base < Grape::API
      # Contains all the constant that will be used for development
      include ThirdPartyService::Thanos::V1::Helpers::Constants
      include Grape::Kaminari

      # Helpers to send success or failure message to frontend
      helpers ThirdPartyService::Thanos::V1::Helpers::ResponseHelper

      # Versioning and Formatting

      version 'v1', using: :path
      format :json
      prefix :api
      formatter :json, Grape::Formatter::Json

      before do
        ActiveStorage::Current.host = request.base_url
        auth_optional = route&.settings&.dig(:authentication, :optional)
        if auth_optional
          # allow guest users if the endpoint specifies so
          Rails.logger.info 'Authentication optional for this endpoint'
        else
          unless authenticated!
            error!(failure_response_with_json('Unauthorized access', HTTP_CODE[:UNAUTHORIZED]),
                   HTTP_CODE[:UNAUTHORIZED])
          end
          set_audited_user
        end
      end

      helpers do
        def authenticated!
          auth_key = AuthorizationKey.find_by(token: bearer_token)
          if auth_key.present? && !auth_key.is_expired? && auth_key.authable.staffable.thanos?
            @current_staff = auth_key.authable
          end
        rescue StandardError => ex
          Rails.logger.error "Error occurs during Authentication. Message: #{ex.full_message}"
          error!('Something went wrong', 500)
        end

        def set_audited_user
          Audited.store[:audited_user] = @current_staff
        end

        def bearer_token
          request.headers.fetch('Authorization', '').split(' ').last
        end
      end

      @error = []
      # API Mounts with Grape
      mount Thanos::V1::Staffs
      mount Thanos::V1::ProductAttributes
      mount Thanos::V1::Suppliers
      mount Thanos::V1::Products
      mount Thanos::V1::Variants

      HTTP_ERROR = [400, 401, 403, 404, 409, 422, 500, 503, 999].freeze
    end
  end
end
