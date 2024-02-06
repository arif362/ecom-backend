module ShopothWarehouse
  module V1
    module Entities
      class RetailerAssistants < Grape::Entity
        expose :id
        expose :distributor_id
        expose :distributor_name
        expose :name
        expose :phone
        expose :email, safe: true
        expose :status
        expose :category

        def distributor_name
          object&.distributor&.name
        end
      end
    end
  end
end
