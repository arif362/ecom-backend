# frozen_string_literal: true

module ThirdPartyService
  module V1
    module Entities
      class User < Grape::Entity
        expose :full_name, as: :name
        expose :email
        expose :phone
        expose :date_of_birth
        expose :gender
        expose :created_at, as: :registration_at
        expose :partner_code
        expose :has_smart_phone
        expose :is_app_download
        expose :status
        expose :ra_phone

        def is_app_download
          object.is_app_download
        end

        def has_smart_phone
          object.has_smart_phone
        end
      end
    end
  end
end
