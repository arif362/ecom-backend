module ShopothRider
  class Base < Grape::API
    # Contains all the constant that will be used for development
    include ShopothRider::V1::Helpers::Constants
    include ShopothRider::V1::Helpers::ImageHelper

    # Helpers to send success or failure message to frontend
    helpers ShopothRider::V1::Helpers::ResponseHelper

    helpers ShopothRider::V1::Helpers::ImageHelper

    helpers CommonHelper

    version 'v1', using: :path
    format :json
    prefix :api
    formatter :json, Grape::Formatter::Json

    #############################
    # Rider JWT Authentication
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
      set_audited_user
    end

    helpers do
      def authenticated!
        auth_key = AuthorizationKey.find_by(token: bearer_token)
        if auth_key.present? && !auth_key.is_expired?
          @current_rider = auth_key.authable
        else
          error!({ message: 'Unauthorized.', status_code: 401 }, 401)
        end
      rescue StandardError => error
        Rails.logger.error "Authentication failed due to: #{error.message}"
        error!({ message: 'Unauthorized.', status_code: 401 }, 401)
      end

      def set_audited_user
        Audited.store[:audited_user] = @current_rider
      end

      def bearer_token
        request.headers.fetch('Authorization', '').split(' ').last
      end
    end

    @error = []

    mount V1::CustomerOrders
    mount V1::Riders
    mount V1::AppNotifications
    mount V1::ReturnOrders

    HTTP_ERROR = [400, 401, 403, 404, 422, 500, 503, 999].freeze
  end
end
