# frozen_string_literal: true

module ShopothWarehouse
  module V1
    module Entities
      class ExportVariants < Grape::Entity
        include ShopothWarehouse::V1::Helpers::ImageHelper
        expose :id, as: :shopoth_variant_id
        expose :product_id, as: :shopoth_product_id
        expose :title
        expose :description
        expose :short_description
        expose :brand
        expose :material
        expose :product_specifications
        expose :status
        expose :sku
        expose :price_agami_trade, as: :price
        expose :vat_tax, as: :vat
        expose :consumer_discount, as: :discount

        def title
          object.product&.title.present? ? object.product&.title : ""
        end

        def description
          object.product&.description.present? ? object.product&.description : ""
        end

        def short_description
          object.product&.short_description.present? ? object.product&.short_description : ""
        end

        def brand
          object.product&.brand.present? ? object.product&.brand : ""
        end

        def material
          object.product&.material.present? ? object.product&.material : ""
        end

        def product_specifications
          object.product&.product_specifications.present? ? object.product&.product_specifications : ""
        end

        def status
          object.product&.status.present? ? object.product&.status : ""
        end

      end
    end
  end
end
