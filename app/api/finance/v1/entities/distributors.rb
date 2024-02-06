module Finance
  module V1
    module Entities
      class Distributors < Grape::Entity
        expose :id
        expose :name
        expose :bn_name
        expose :warehouse_id
        expose :email
        expose :phone
        expose :address
        expose :code
        expose :status
      end
    end
  end
end
