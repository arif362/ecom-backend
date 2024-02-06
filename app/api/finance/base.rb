module Finance
  class Base < Grape::API
    # Contains all the constant that will be used for development
    include Finance::V1::Helpers::Constants
    include Finance::V1::Helpers::ImageHelpers
    include Grape::Kaminari

    PAGINATION_MAX_PER_PAGE = 300
    PAGINATION_DEFAULT_PER_PAGE = 50

    # Helpers to send success or failure message to frontend
    helpers Finance::V1::Helpers::ResponseHelpers

    ############################
    # Versioning and Formatting
    #############################
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
      if auth_optional
        # allow guest users if the endpoint specifies so
        Rails.logger.info 'Authentication optional for this endpoint'
      elsif authenticated!
        set_audited_user
      else
        error!('401 Unauthorized', 401)
      end
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
        payload = JsonWebToken.decode(bearer_token)
        @current_staff = Staff.finance.find_by(id: payload['sub'])
        payload['exp'] >= Time.now.to_i && @current_staff.present?
      rescue StandardError => ex
        Rails.logger.error "Authentication failed due to: #{ex.full_message}"
        error!('Something went wrong.', 500)
      end

      def set_audited_user
        Audited.store[:audited_user] = @current_staff
      end

      def bearer_token
        request.headers.fetch('Authorization', '').split(' ').last
      end

      def check_dh_warehouse
        @current_staff&.warehouse&.warehouse_type == Warehouse::WAREHOUSE_TYPES[:distribution]
      end

      def check_central_warehouse
        @current_staff&.warehouse&.warehouse_type == Warehouse::WAREHOUSE_TYPES[:central]
      end
    end

    @error = []

    mount V1::Staffs
    mount V1::BankAccounts
    mount V1::CustomerOrders
    mount V1::BankTransactions
    mount V1::Warehouses
    mount V1::WhPurchaseOrders
    mount V1::Suppliers
    mount V1::Variants
    mount V1::PaymentReports
    mount V1::PaymentHistories
    mount V1::Distributors
    mount V1::CustomerAcquisitions
  end
end
