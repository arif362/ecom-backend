module ShopothWarehouse
  module V1
    module Entities
      class ProductList < Grape::Entity
        include ShopothWarehouse::V1::Helpers::ImageHelper

        expose :id
        expose :title
        expose :slug
        expose :company
        expose :max_quantity_per_order
        expose :brand
        expose :hero_image
        expose :supplier_tag

        def hero_image
          begin
            object&.hero_image.variable? ? image_variant_path(object&.hero_image)&.dig(:mini_img) : object&.hero_image.service_url
          rescue ActiveStorage::FileNotFoundError
            nil
          rescue => ex
            nil
          end
        end

        def supplier_tag
          object.suppliers_variants.present?
        end

        def brand
          object&.brand&.name
        end
      end
    end
  end
end
