module ShopothPartner
  module V1
    module Entities
      class BnResult < Grape::Entity
        expose :id
        expose :bn_title, as: :title
        expose :bn_message, as: :message
        expose :read
        expose :created_at

        def created_at
          object.created_at.to_s.to_bn.first(19)
        end
      end
    end
  end
end
