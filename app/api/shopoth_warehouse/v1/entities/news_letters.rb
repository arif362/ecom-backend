module ShopothWarehouse
  module V1
    module Entities
      class NewsLetters < Grape::Entity
        expose :id
        expose :email
        expose :is_active
      end
    end
  end
end
