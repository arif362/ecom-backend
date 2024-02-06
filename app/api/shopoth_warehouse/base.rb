module ShopothWarehouse
  class Base < Grape::API
    # Contains all the constant that will be used for development
    include ShopothWarehouse::V1::Helpers::Constants
    include ShopothWarehouse::V1::Helpers::ImageHelper
    include Grape::Kaminari

    PAGINATION_MAX_PER_PAGE = 300
    PAGINATION_DEFAULT_PER_PAGE = 50

    # Helpers to send success or failure message to frontend
    helpers ShopothWarehouse::V1::Helpers::ResponseHelper

    helpers ShopothWarehouse::V1::Helpers::ImageHelper

    # Adding to use common helper methods
    helpers CommonHelper

    version 'v1', using: :path
    format :json
    prefix :api
    formatter :json, Grape::Formatter::Json

    #############################
    # Warehouse JWT Authentication
    #############################

    before do
      ActiveStorage::Current.host = request.base_url
      auth_optional = route&.settings&.dig(:authentication, :optional)
      auth_type = route&.settings&.dig(:authentication, :type)
      if auth_optional
        # allow guest users if the endpoint specifies so
        Rails.logger.info 'Authentication optional for this endpoint'
      elsif auth_type && auth_type == RouteDevice
        error!('401 Unauthorized', 401) unless route_device_authenticated!
      elsif authenticated!
        set_warehouse
        set_audited_user
      else
        error!('401 Unauthorized', 401)
      end
      set_language
    end

    # pagination
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

    helpers do
      def authenticated!
        auth_key = AuthorizationKey.find_by(token: bearer_token)
        @current_staff = auth_key.authable if auth_key.present? && !auth_key.is_expired?
      rescue StandardError => ex
        Rails.logger.error "Authentication failed due to: #{ex.full_message}"
        error!('Something went wrong.', 500)
      end

      def set_audited_user
        Audited.store[:audited_user] = @current_staff
      end

      def route_device_authenticated!
        auth_key = AuthorizationKey.find_by(token: bearer_token)
        @current_route_device = auth_key.authable if auth_key.present? && !auth_key.is_expired?
      rescue StandardError => ex
        Rails.logger.error "Authentication failed due to: #{ex.full_message}"
        false
      end

      def bearer_token
        request.headers.fetch('Authorization', '').split(' ').last
      end

      def set_warehouse
        @current_warehouse = @current_staff&.warehouse
      end

      def check_dh_warehouse
        @current_staff&.warehouse&.warehouse_type == Warehouse::WAREHOUSE_TYPES[:distribution] ||
          @current_staff&.warehouse&.warehouse_type == Warehouse::WAREHOUSE_TYPES[:member] ||
          @current_staff&.warehouse&.warehouse_type == Warehouse::WAREHOUSE_TYPES[:b2b]
      end

      def check_wh_warehouse
        @current_staff&.warehouse&.warehouse_type == Warehouse::WAREHOUSE_TYPES[:central]
      end

      def set_language
        @locale = extract_language == 'bn' ? :bn : :en
        I18n.locale = @locale
      end

      def extract_language
        request.headers.fetch('Language-Type', '').split(' ').last
      end
    end

    @error = []

    mount V1::Warehouses
    mount V1::Suppliers
    mount V1::Products
    mount V1::Addresses
    mount V1::Categories
    mount V1::ShopothVehicles
    mount V1::Questionnaires
    mount V1::WarehouseStorages
    mount V1::PurchaseOrderInvoices
    mount V1::DhPurchaseOrders
    mount V1::WhPurchaseOrders
    mount V1::SalesRepresentatives
    mount V1::PartnerShops
    mount V1::ProductAttributes
    mount V1::Districts
    mount V1::Thanas
    mount V1::Areas
    mount V1::Permissions
    mount V1::StaffRoles
    mount V1::Staffs
    mount V1::Sessions
    mount V1::DhManagerStaffs
    mount V1::WarehouseVariants
    mount V1::StorageVariants
    mount V1::Partners
    mount V1::Slides
    mount V1::Routes
    mount V1::RouteDevices
    mount V1::ProductTypes
    mount V1::LineItems
    mount V1::Qcs
    mount V1::QrCodes
    mount V1::UserDetails
    mount V1::Invoices
    mount V1::CustomerCareReports
    mount V1::ReturnOrders
    mount V1::CustomerOrderList
    mount V1::AppNotifications
    mount V1::Riders
    mount V1::OrderStatuses
    mount V1::RouteReturns
    mount V1::Locations
    mount V1::WarehouseVariantsLocations
    mount V1::Dashboard
    mount V1::Coupons
    mount V1::Inventories
    mount V1::RetailerAssistants
    mount V1::Promotions
    mount V1::BlockedItems
    mount V1::AggregateReturns
    mount V1::NewsLetters
    mount V1::BankTransactions
    mount V1::BankAccounts
    mount V1::CustomerOrders
    mount V1::RouteMargins
    mount V1::Reviews
    mount V1::RequestedVariants
    mount V1::Brands
    mount V1::ProductFeatures
    mount V1::AttributeSets
    mount V1::HelpTopics
    mount V1::Articles
    mount V1::ContactUs
    mount V1::Feedbacks
    mount V1::Searches
    mount V1::Bundles
    mount V1::FlashSales
    mount V1::StaticPages
    mount V1::Slugs
    mount V1::Distributors
    mount V1::AppConfigs
    mount V1::ReturnTransferOrders
    mount V1::PromoCoupons
    mount V1::PromoBanners
    mount V1::Challans
    mount V1::ReturnChallans
    mount V1::UserModifyReasons
    mount V1::AuditLogs
    mount V1::Variants
    mount V1::CustomerAcquisitions

    HTTP_ERROR = [400, 401, 403, 404, 422, 500, 503, 999].freeze
  end
end
