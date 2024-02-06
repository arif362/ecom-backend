# frozen_string_literal: true

module Ecommerce
  module V1
    module Entities
      class UserPreferences < Grape::Entity
        expose :id
        expose :default_delivery_method
        expose :mail_notification
        expose :smart_notification
        expose :cellular_notification
        expose :subscription
      end
    end
  end
end
