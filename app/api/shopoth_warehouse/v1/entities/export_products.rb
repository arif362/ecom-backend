# frozen_string_literal: true

module ShopothWarehouse
  module V1
    module Entities
      class ExportProducts < Grape::Entity
        expose :id, as: :shopoth_product_id
        expose :title
        expose :description
        expose :short_description
        expose :brand
        expose :material
        expose :product_specifications
        expose :status
        expose :variants_attributes do |product, _options|
          ShopothWarehouse::V1::Entities::ExportVariants.represent(product.variants)
        end
      end
    end
  end
end
