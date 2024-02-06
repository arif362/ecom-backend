
# frozen_string_literal: true

module Finance
  module V1
    module Entities
      class CustomerAcquisitions < Grape::Entity
        expose :id
        expose :user_id
        expose :registered_by_id
        expose :registered_by_type
        expose :amount
        expose :coupon_id
        expose :is_paid
        expose :information_status
        expose :created_at
        expose :details_view, merge: true

        def details_view
          # return if options[:list]
          hash = {
            user: object.user&.full_name,
          }
          if object.registered_by&.class&.to_s == 'Partner'
            hash[:registered_by] = object.registered_by&.name
          elsif object.registered_by&.class&.to_s == 'RouteDevice'
            hash[:registered_by] = object.registered_by&.route&.sr_name
          else
            hash[:registered_by] = object.registered_by&.ambassador&.preferred_name
          end
          hash
        end
      end
    end
  end
end
