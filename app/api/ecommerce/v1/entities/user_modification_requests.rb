module Ecommerce
  module V1
    module Entities
      class UserModificationRequests < Grape::Entity
        expose :request_type
        expose :status
        expose :user_modify_reason, merge: true
        expose :reason

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
