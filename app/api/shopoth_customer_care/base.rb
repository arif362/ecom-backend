module ShopothCustomerCare
  class Base < Grape::API
    # Contains all the constant that will be used for development
    include ShopothCustomerCare::V1::Helpers::Constants
    include ShopothCustomerCare::V1::Helpers::ImageHelper
    include Grape::Kaminari

    # Helpers to send success or failure message to frontend
    helpers ShopothCustomerCare::V1::Helpers::ResponseHelper

    helpers ShopothCustomerCare::V1::Helpers::ImageHelper

    version 'v1', using: :path
    format :json
    prefix :api
    formatter :json, Grape::Formatter::Json

    #############################
    # Customer Care User JWT Authentication
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
        if auth_key.present? && !auth_key.is_expired? && auth_key.authable.customer_care? && auth_key.authable.staffable.active?
          @current_customer_care_agent = auth_key.authable
        else
          error!({ message: 'Unauthorized.', status_code: 401 }, 401)
        end
      rescue StandardError => error
        Rails.logger.error "Authentication failed due to: #{error.message}"
        error!({ message: 'Unauthorized.', status_code: 401 }, 401)
      end

      def set_audited_user
        Audited.store[:audited_user] = @current_customer_care_agent
      end

      def bearer_token
        request.headers.fetch('Authorization', '').split(' ').last
      end
    end

    @error = []

    mount V1::CustomerCareAgents
    mount V1::Users
    mount V1::Customers
    mount V1::Partners
    mount V1::CustomerOrders
    mount V1::ReturnOrders
    mount V1::OrderStatuses
    mount V1::Districts
    mount V1::Thanas
    mount V1::Areas
    mount V1::AggregateReturns
    mount V1::UserModificationRequests

    HTTP_ERROR = [400, 401, 403, 404, 422, 500, 503, 999].freeze
  end
end
