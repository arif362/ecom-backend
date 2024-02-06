module ThirdPartyService
  class Base < Grape::API
    # Contains all the constant that will be used for development
    include ThirdPartyService::V1::Helpers::Constants
    include Grape::Kaminari

    # Helpers to send success or failure message to frontend
    helpers ThirdPartyService::V1::Helpers::ResponseHelper

    helpers CommonHelper

    version 'v1', using: :path
    format :json
    prefix :api
    formatter :json, Grape::Formatter::Json

    #############################
    # ThirdPartyUser JWT Authentication
    #############################

    before do
      ActiveStorage::Current.host = request.base_url
      auth_optional = route&.settings&.dig(:authentication, :optional)
      if auth_optional
        # allow guest users if the endpoint specifies so
        Rails.logger.info 'Authentication optional for this endpoint'
      else
        unless authenticated!
          error!(respond_with_json('Unauthorized access', HTTP_CODE[:UNAUTHORIZED]),
                 HTTP_CODE[:UNAUTHORIZED])
        end
      end
    end

    helpers do
      def authenticated!
        auth_key = AuthorizationKey.find_by(token: bearer_token)
        if auth_key.present? && !auth_key.is_expired?
          @current_third_party_user = auth_key.authable
        end
      rescue StandardError => ex
        Rails.logger.error "Error occurs during Authentication. Message: #{ex.full_message}"
        error!('Something went wrong', 500)
      end

      def bearer_token
        request.headers.fetch('Authorization', '').split(' ').last
      end
    end

    @error = []

    mount V1::ThirdPartyUsers
    mount V1::RetailerAssistants

    HTTP_ERROR = [400, 401, 403, 404, 409, 422, 500, 503, 999].freeze
  end
end
