module ShopothPartner
  module V1
    module Entities
      class PartnerVariantsAttributeValues < Grape::Entity
        expose :id
        expose :value
        expose :product_attribute_id
        expose :product_attribute_name

        def product_attribute_name
          object&.product_attribute&.name
        end
      end
    end
  end
end
