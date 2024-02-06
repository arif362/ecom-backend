# frozen_string_literal: true

module ShopothDistributor
  class Base < Grape::API
    # Contains all the constant that will be used for development
    include ShopothDistributor::V1::Helpers::Constants

    # Helpers to send success or failure message to frontend
    helpers ShopothDistributor::V1::Helpers::ResponseHelper

    # Adding to use common helper methods
    helpers CommonHelper

    # Helpers to fetch image path
    # helpers Ecommerce::V1::Helpers::ImageHelper

    ########################################
    # Distribution panel JWT Authentication
    ########################################
    before do
      ActiveStorage::Current.host = request.base_url
      auth_optional = route&.settings&.dig(:authentication, :optional)
      if auth_optional
        Rails.logger.info 'Authentication optional for this endpoint'
      else
        authenticated!
      end
      set_distributor
      set_audited_user
    end

    helpers do
      def authenticated!
        auth_key = AuthorizationKey.find_by(token: bearer_token)
        if auth_key.present? && !auth_key.is_expired? && auth_key.authable.dh_panel? && auth_key.authable.staffable.active?
          @current_staff = auth_key.authable
        else
          error!({ message: 'Unauthorized.', status_code: 401 }, 401)
        end
      rescue StandardError => error
        Rails.logger.error "Authentication failed due to: #{error.message}"
        error!({ message: 'Unauthorized.', status_code: 401 }, 401)
      end

      def bearer_token
        request.headers.fetch('Authorization', '').split(' ').last
      end

      def set_distributor
        @current_distributor = @current_staff&.staffable
      end

      def set_audited_user
        Audited.store[:audited_user] = @current_staff
      end
    end

    include Grape::Kaminari

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
    mount V1::Distributors
    mount V1::Riders
    mount V1::Warehouses
    mount V1::Routes
    mount V1::BankTransactions
    mount V1::Partners
    mount V1::RetailerAssistants
    mount V1::Routes
    mount V1::RouteDevices
    mount V1::CustomerOrders
    mount V1::ReturnOrders
    mount V1::Dashboard
    mount V1::ReturnChallans
    mount V1::Challans
    mount V1::OrderStatuses
    mount V1::BankAccounts
    mount V1::RouteMargin
    mount V1::AggregateReturns
    mount V1::Thanas

    ###### END of Module Mounting #####
  end
end
