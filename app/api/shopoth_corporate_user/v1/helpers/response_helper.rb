# frozen_string_literal: true
module ShopothCorporateUser::V1::Helpers
  module ResponseHelper
    extend Grape::API::Helpers

    def respond_with_json(msg, status_code)
      { message: msg, status_code: status_code }
    end
  end
end
