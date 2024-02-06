# frozen_string_literal: true
module ShopothWarehouse::V1::Helpers
  module ResponseHelper
    extend Grape::API::Helpers

    def respond_with_json(msg, status_code)
      { message: msg, status_code: status_code }
    end

    def success_response_with_json(msg, status_code, data = {})
      {
        success: true,
        status: status_code,
        message: msg,
        data: data,
      }
    end

    def failure_response_with_json(msg, status_code, data = {})
      {
        success: false,
        status: status_code,
        message: msg,
        data: data,
      }
    end

    def grape_success_response(response_class_name, status_code, message, data)
      present :success, true
      present :status, status_code
      present :message, message
      present :data, data, with: response_class_name
    end
  end
end
