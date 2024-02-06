module ShopothPartner
  module V1
    module Entities
      class BnPartnerProducts < Grape::Entity
        include ShopothPartner::V1::Helpers::ImageHelper

        expose :id, as: :product_id
        expose :title do |model, options|
          model.bn_title
        end
        expose :description do |model, options|
          model.bn_description
        end
        expose :short_description do |model, options|
          model.bn_short_description
        end
        expose :warranty_period
        expose :warranty_policy do |model, options|
          model.bn_warranty_policy
        end
        expose :video_url
        expose :warranty_type # enum
        expose :warranty_period_type
        expose :company do |model, options|
          model.bn_company
        end
        expose :bn_brand, as: :brand
        expose :certification do |model, options|
          model.bn_certification
        end
        expose :license_required
        expose :material do |model, options|
          model.bn_material
        end
        expose :consumption_guidelines do |model, options|
          model.bn_consumption_guidelines
        end
        expose :temperature_requirement do |model, options|
          model.bn_temperature_requirement
        end
        expose :keywords
        expose :brand_message
        expose :tagline
        expose :hero_image
        expose :images
        expose :product_attribute_values
        expose :variants

        def product_attribute_values
          warehouse = options[:warehouse]
          product_attribute = object.variants.map do |variant|
            available_quantity = WarehouseVariant.find_by(variant: variant, warehouse: warehouse)&.available_quantity
            next unless available_quantity.to_i.positive?

            variant.product_attribute_values.map do |attr_val|
              {
                name: attr_val&.product_attribute&.name,
                # options[:language] == 'en' ? attr_val.product_attribute.name : attr_val.product_attribute.bn_name,
                # bn_name: attr_val&.product_attribute&.bn_name,
                id: attr_val&.id,
                value: attr_val&.value,
                bn_value: attr_val&.bn_value,
                images: attribute_images(ProductAttributeImage.
                  where(product_id: variant.product.id, product_attribute_value_id: attr_val.id )),
              }
            end
          end.compact.flatten.uniq.group_by { |h| h && h[:name] }

          product_attribute.map do |key, value|
            {
              product_attribute_name: key,
              product_attribute_values: value.map { |h| { id: h[:id], value: h[:bn_value], images: h[:images] } },
            }
          end
        end

        def variants
          warehouse = options[:warehouse]
          variants = []
          object.variants.each do |variant|
            available_quantity = WarehouseVariant.find_by(variant: variant, warehouse: warehouse)&.available_quantity
            next unless available_quantity.to_i.positive?

            variants << ShopothPartner::V1::Entities::PartnerProductsVariants.represent(variant,
                                                                                        available_quantity: available_quantity,
                                                                                        b2b: options[:b2b])
          end
          variants
        end

        def image_path_for_attachment(image)
          image.service_url if image.present?
        end

        def attribute_images(attribute_images)
          arr ||= []
          attribute_images.each do |attribute_image|
            attribute_image.images.each do |image|
              arr << image_path_for_attachment(image)
            end
          end
          arr.present? ? arr : nil
        end

        def hero_image
          image_path(object.hero_image)
        end

        def images
          image_paths(object.images)
        end

        def bn_brand
          object&.brand&.bn_name
        end
      end
    end
  end
end
