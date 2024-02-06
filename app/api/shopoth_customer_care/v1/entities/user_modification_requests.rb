module ShopothCustomerCare
  module V1
    module Entities
      class UserModificationRequests < Grape::Entity
        expose :id
        expose :request_type
        expose :user, merge: true
        expose :status
        expose :user_modify_reason, merge: true
        expose :reason

        def user
          user = User.unscoped.find_by(id: object.user_id)
          {
            user_id: user&.id,
            user_name: user&.name,
            user_phone: user&.phone,
            user_email: user&.email,
            user_status: user&.status,
          }
        end
        def user_modify_reason
          user_modify_reason = object.user_modify_reason
          {
            user_modify_reason_id: user_modify_reason&.id,
            user_modify_reason_title: user_modify_reason&.title,
            user_modify_reason_title_bn: user_modify_reason&.title_bn,
          }
        end
      end
    end
  end
end
