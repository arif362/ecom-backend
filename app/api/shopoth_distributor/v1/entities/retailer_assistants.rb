module ShopothDistributor
  module V1
    module Entities
      class RetailerAssistants < Grape::Entity
        expose :id
        expose :name
        expose :phone
        expose :email, safe: true
        expose :status
        expose :category
      end
    end
  end
end
