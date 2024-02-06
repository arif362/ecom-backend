module ShopothPartner
  class Base < Grape::API
    # Contains all the constant that will be used for development
    include ShopothPartner::V1::Helpers::Constants
    include ShopothPartner::V1::Helpers::ImageHelper
    include Grape::Kaminari

    # Helpers to send success or failure message to frontend
    helpers ShopothPartner::V1::Helpers::ResponseHelper

    helpers ShopothPartner::V1::Helpers::ImageHelper

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
      auth_type = route&.settings&.dig(:authentication, :type)
      if auth_optional
        # allow guest users if the endpoint specifies so
        Rails.logger.info 'Authentication optional for this endpoint'
      elsif auth_type && auth_type == RetailerAssistant
        error!('401 Unauthorized', 401) unless retailer_assistant_authenticated!
      elsif auth_type && auth_type == 'Both'
        error!('401 Unauthorized', 401) unless partner_ra_authenticated!
      else
        error!('401 Unauthorized', 401) unless authenticated!
      end
      set_language
      set_audited_user
      set_business_type
    end

    helpers do
      def authenticated!
        payload = JsonWebToken.decode(bearer_token)
        payload['exp'] >= Time.now.to_i &&
          @current_partner = Partner.find_by(id: payload['partner_id'])
      rescue StandardError
        false
      end

      def set_audited_user
        Audited.store[:audited_user] = @current_partner
      end

      def partner_ra_authenticated!
        payload = JsonWebToken.decode(bearer_token)
        if payload['exp'] >= Time.now.to_i
          @current_partner = Partner.find_by(id: payload['partner_id'])
          @current_retailer = RetailerAssistant.find_by(id: payload['retailer_id'])
          [@current_partner, @current_retailer]
        end
      rescue StandardError
        false
      end

      def retailer_assistant_authenticated!
        payload = JsonWebToken.decode(bearer_token)
        payload['exp'] >= Time.now.to_i &&
          @current_retailer = RetailerAssistant.find_by(id: payload['retailer_id'])
      rescue StandardError
        false
      end

      def set_language
        @locale = extract_language == 'bn' ? :bn : :en
        I18n.locale = @locale
      end

      def set_business_type
        @business_type = check_b2b? ? 'b2b' : 'b2c'
      end

      def bearer_token
        request.headers.fetch('Authorization', '').split(' ').last
      end

      def extract_language
        request.headers.fetch('Language-Type', '').split(' ').last
      end

      def member_partner
        warehouse = Warehouse.find_by(id: @current_partner.route.warehouse_id)
        warehouse.warehouse_type == Warehouse::WAREHOUSE_TYPES[:member] ? @current_partner : nil
      end

      def check_b2b?
        request.headers.fetch('Business-Type', '').split(' ').last == 'b2b'
      end
    end

    @error = []

    mount V1::Partners
    mount V1::AppNotifications
    mount V1::ReturnOrders
    mount V1::CustomerOrders
    mount V1::Customers
    mount V1::Passwords
    mount V1::Products
    mount V1::Categories
    mount V1::Carts
    mount V1::Orders
    mount V1::Otps
    mount V1::RetailerAssistants
    mount V1::CustomerAcquisitions
    mount V1::Payments
    HTTP_ERROR = [400, 401, 403, 404, 422, 500, 503, 999].freeze
  end
end
