module Ecommerce
  module V1
    module Entities
      class ProductTypes < Grape::Entity
        expose :id
        expose :title
      end
    end
  end
end
