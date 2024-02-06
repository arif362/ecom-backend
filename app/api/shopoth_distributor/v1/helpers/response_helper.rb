# frozen_string_literal: true

module ShopothDistributor
  module V1
    module Helpers
      module ResponseHelper
        extend Grape::API::Helpers
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
      end
    end
  end
end
