# frozen_string_literal: true

module Ecommerce
  class Base < Grape::API
    # Contains all the constant that will be used for development
    include Ecommerce::V1::Helpers::Constants

    # Helpers to send success or failure message to frontend
    helpers Ecommerce::V1::Helpers::ResponseHelper

    # Helpers to fetch image path
    helpers Ecommerce::V1::Helpers::ImageHelper

    # Adding to use common helper methods
    helpers CommonHelper

    #############################
    # Ecommerce JWT Authentication
    #############################

    before do
      ActiveStorage::Current.host = request.base_url
      auth_optional = route&.settings&.dig(:authentication, :optional)
      if auth_optional
        Rails.logger.info 'Authentication optional for this endpoint'
        @current_user unless authenticated!
      else
        error!('401 Unauthorized', 401) unless authenticated!
      end
      set_language_for_ecom
      set_request_source
      set_audited_user
    end

    helpers do
      def authenticated!
        auth_key = AuthorizationKey.find_by(token: bearer_token)
        if auth_key.present? && !auth_key.is_expired? && auth_key.authable_type == 'User' && auth_key.authable.active? && auth_key.authable.is_otp_verified
          @current_user = auth_key.authable
        else
          payload = JsonWebToken.decode(bearer_token)
          @current_user = Partner.find_by(id: payload['partner_id']) if payload['exp'] >= Time.now.to_i
        end
      rescue StandardError
        false
      end

      def set_language_for_ecom
        @locale = extract_language == 'bn' ? :bn : :en
        I18n.locale = @locale
      end

      def set_request_source
        @request_source = extract_host == 'app' ? :app : :web
      end

      def set_audited_user
        Audited.store[:audited_user] = @current_user
      end

      def bearer_token
        request.headers.fetch('Authorization', '').split(' ').last
      end

      def extract_language
        request.headers.fetch('Accept-Language', '').split(' ').last
      end

      def extract_host
        request.headers.fetch('Request-Source', '').split(' ').last
      end

      def user_domain
        domain = request.headers.fetch('Sub-Domain', '').split(' ').last
        return unless domain.present? && @current_user.present?

        return unless domain == "#{ENV['MEMBER_WAREHOUSE']}" && @current_user.member?

        domain
      end
    end

    #
    # Pagination
    #
    include Grape::Kaminari
    PAGINATION_MAX_PER_PAGE = 300
    PAGINATION_DEFAULT_PER_PAGE = 50

    before do
      # grape-kaminari will always return a page header of the given per_page param
      # and not the really used (and maybe enforced) value
      if params[:per_page] && params[:per_page].to_i > PAGINATION_MAX_PER_PAGE
        params[:per_page] = PAGINATION_MAX_PER_PAGE
      end

      # # grape-kaminari will not return a header with the default value of 50 if there was no
      # # per_page param
      # params[:per_page] = PAGINATION_DEFAULT_PER_PAGE unless params[:per_page]
    end

    #############################
    # Versioning and Formatting
    #############################
    version 'v1', using: :path
    format :json
    prefix :api
    formatter :json, Grape::Formatter::Json

    #############################
    # API Mounts with Grape
    #############################
    mount V1::Slugs
    mount V1::Users
    mount V1::ShopothLineItems
    mount V1::CustomerOrders
    mount V1::Homepage
    mount V1::Carts
    mount V1::Wishlists
    mount V1::Payments
    mount V1::Reviews
    mount V1::UserPreferences
    mount V1::StaticPages
    mount V1::StoreInfos
    mount V1::Footer
    mount V1::SocialLinks
    mount V1::ProductCategory
    mount V1::Brands
    mount V1::ProductView
    mount V1::Otps
    mount V1::Notifications
    mount V1::PickDistrict
    mount V1::ReturnCustomerOrders
    mount V1::ThanaSearch
    mount V1::AreaSearch
    mount V1::PartnerSearch
    mount V1::Coupons
    mount V1::PartnerRanking
    mount V1::Recommendations
    mount V1::RequestedVariants
    mount V1::Partners
    mount V1::Sliders
    mount V1::ProductSearch
    mount V1::HelpTopics
    mount V1::Articles
    mount V1::ContactUs
    mount V1::Feedbacks
    mount V1::OrderTrackings
    mount V1::Sitemaps
    mount V1::FlashSales
    mount V1::StaticPages
    mount V1::Configurations
    mount V1::CustomerDevices
    mount V1::PromoCoupons
    mount V1::PromoBanners
    mount V1::SearchItems
    mount V1::UserModificationRequests
    mount V1::UserModifyReasons
    mount V1::Ambassadors
    mount V1::CustomerAcquisitions
    mount V1::AppNotifications

    ###### END of Module Mounting #####
    HTTP_ERROR = [400, 401, 403, 404, 422, 500, 503, 999].freeze
  end
end
