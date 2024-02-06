module Finance
  module V1
    module Entities
      class Warehouses < Grape::Entity
        expose :id
        expose :name
        expose :email
        expose :phone
      end
    end
  end
end
