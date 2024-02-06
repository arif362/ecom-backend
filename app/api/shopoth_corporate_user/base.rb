module ShopothCorporateUser
  class Base < Grape::API
    # Contains all the constant that will be used for development
    include ShopothCorporateUser::V1::Helpers::Constants
    include ShopothCorporateUser::V1::Helpers::ImageHelper

    # Helpers to send success or failure message to frontend
    helpers ShopothCorporateUser::V1::Helpers::ResponseHelper

    helpers ShopothCorporateUser::V1::Helpers::ImageHelper

    version 'v1', using: :path
    format :json
    prefix :api
    formatter :json, Grape::Formatter::Json

    #############################
    # Corporate User JWT Authentication
    #############################

    before do
      ActiveStorage::Current.host = request.base_url
      auth_optional = route&.settings&.dig(:authentication, :optional)
      if auth_optional
        # allow guest users if the endpoint specifies so
        Rails.logger.info 'Authentication optional for this endpoint'
      else
        error!('401 Unauthorized', 401) unless authenticated!
      end
    end

    helpers do
      def authenticated!
        payload = JsonWebToken.decode(bearer_token)
        payload['exp'] >= Time.now.to_i &&
          @current_corporate_user = CorporateUser.find_by(id: payload['sub'])
      rescue StandardError
        false
      end

      def bearer_token
        request.headers.fetch('Authorization', '').split(' ').last
      end
    end

    @error = []

    mount V1::CorporateUsers
    mount V1::Products

    HTTP_ERROR = [400, 401, 403, 404, 422, 500, 503, 999].freeze
  end
end
