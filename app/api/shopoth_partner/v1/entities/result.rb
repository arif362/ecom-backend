module ShopothPartner
  module V1
    module Entities
      class Result < Grape::Entity
        expose :id
        expose :title
        expose :message
        expose :read
        expose :created_at

        def created_at
          object.created_at.to_s.first(19)
        end
      end
    end
  end
end
