module ShopothWarehouse
  module V1
    module Entities
      class Feedbacks < Grape::Entity
        expose :id
        expose :message
        expose :rating
        expose :user_id
        expose :user_name
        expose :user_phone

        def user_name
          user&.full_name
        end

        def user_phone
          user&.phone
        end

        def user
          @user ||= object.user
        end
      end
    end
  end
end
