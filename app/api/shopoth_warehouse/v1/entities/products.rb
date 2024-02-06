# frozen_string_literal: true

module ShopothWarehouse
  module V1
    module Entities
      class Products < Grape::Entity
        include ShopothWarehouse::V1::Helpers::ImageHelper

        expose :id
        expose :title
        expose :slug
        expose :description
        expose :bn_title
        expose :bn_description
        expose :is_deleted
        expose :short_description
        expose :bn_short_description
        expose :warranty_period
        expose :warranty_policy
        expose :bn_warranty_policy
        expose :inside_box
        expose :bn_inside_box
        expose :video_url
        expose :warranty_type
        expose :dangerous_goods
        expose :sku_type
        expose :max_quantity_per_order
        expose :warranty_period_type
        expose :company
        expose :bn_company
        expose :brand_id
        expose :brand_name
        expose :return_policy
        expose :bn_return_policy
        expose :certification
        expose :bn_certification
        expose :license_required
        expose :material
        expose :bn_material
        expose :bn_broad_description
        expose :consumption_guidelines
        expose :bn_consumption_guidelines
        expose :temperature_requirement
        expose :bn_temperature_requirement
        expose :keywords
        expose :brand_message
        expose :tagline
        expose :product_type
        expose :product_specifications
        expose :variants
        expose :bundle_variants
        expose :frequently_asked_questions
        # expose :categories
        expose :product_category
        expose :product_types
        expose :hero_image
        expose :hero_image_variant_path
        expose :images
        expose :attribute_value_images
        expose :created_at
        expose :product_features_attributes
        expose :image_attribute_id
        expose :attribute_set_id
        expose :is_refundable
        expose :public_visibility
        expose :meta_info
        expose :weight
        expose :is_emi_available
        expose :tenures
        expose :business_type
        expose :created_by

        def variants
          prod_object.variants.map do |variant|
            ShopothWarehouse::V1::Entities::Variants.represent(variant, warehouse: warehouse).
              as_json.merge(quantity_hash(variant))
          end
        end

        def bundle_variants
          return [] unless prod_object.bundle_product?

          prod_object.variants.first.bundle.bundle_variants.map do |bundle_variant|
            {
              variant_id: bundle_variant.variant_id,
              bundle_sku: bundle_variant.variant&.sku,
              quantity: bundle_variant.quantity,
              is_editable: bundle_variant.bundle.is_editable,
            }
          end&.uniq
        end

        def brand_name
          prod_object&.brand&.name
        end

        def frequently_asked_questions
          prod_object.frequently_asked_questions.map do |faq|
            ShopothWarehouse::V1::Entities::FrequentlyAskedQuestions.represent(faq)
          end
        end

        # TODO : Plz avoid commented code .These below commented code will be removed while integrating to staging
        # def categories
        #   prod_object.categories.map do |category|
        #     ShopothWarehouse::V1::Entities::Categories.represent(category)
        #   end
        # end

        def quantity_hash(variant)
          warehouse_variant = variant.warehouse_variants.find_by(warehouse: warehouse)
          return basic_quantity_hash unless warehouse_variant.present?

          {
            inventory_status: {
              available_quantity: warehouse_variant&.available_quantity.to_i,
              booked_quantity: warehouse_variant&.booked_quantity.to_i,
              packed_quantity: warehouse_variant&.ready_to_ship_from_fc_quantity.to_i,
              blocked_quantity: warehouse_variant&.blocked_quantity.to_i,
              in_transit_quantity: warehouse_variant&.in_transit_quantity.to_i,
              in_partner_quantity: warehouse_variant&.in_partner_quantity.to_i,
            },
          }
        end

        def basic_quantity_hash
          {
            inventory_status: {
              available_quantity: 0,
              booked_quantity: 0,
              packed_quantity: 0,
              blocked_quantity: 0,
            },
          }
        end

        def product_types
          prod_object.product_types.map do |type|
            {
              id: type[:id],
              title: type[:title],
              created_by:
                {
                  id: type[:created_by_id],
                  name: Staff.unscoped.find_by(id: type[:created_by_id])&.name,
                },
            }
          end
        end

        def tenures
          prod_object.tenures.sort
        end

        def hero_image
          begin
            image_path_with_id(prod_object.hero_image)
          rescue => _ex
            nil
          end
        end

        def hero_image_variant_path
          begin
            image_variant_path_with_id(prod_object.hero_image)
          rescue => _ex
            nil
          end
        end

        def images
          begin
            image_paths_with_id(prod_object.images)
          rescue => _ex
            nil
          end
        end
        # TODO : Plz avoid commented code .These below commented code will be removed while integrating to staging
        # def image_path_for_attachment(image)
        #   begin
        #     image.service_url if image.present?
        #   rescue => _ex
        #     nil
        #   end
        # end

        # def attribute_images(images)
        #   arr ||= []
        #   images.each do |image|
        #     arr << { "id" => image.id,
        #              "url" => image_path_for_attachment(image), }
        #   end
        #   arr
        # end

        # def attributes
        #   prod_object&.product_attribute_values.uniq.group_by { |val| val.product_attribute_id }.map do |product_attr_id, product_attr_values|
        #     {
        #       attribute: {
        #         id: product_attr_id,
        #         name: product_attr_values.first.product_attribute.name,
        #       },
        #       attribute_values: product_attr_values.map do |product_attr_value|
        #         {
        #           id: product_attr_value.id,
        #           value: product_attr_value.value,
        #           bn_value: product_attr_value.bn_value,
        #           attribute_image_id: '',
        #           images: product_attr_value.product_attribute_images.where(product_id: prod_object.id).last&.images&.map do |image|
        #             {
        #               id: image.id,
        #               url: image_path_for_attachment(image),
        #             }
        #           end || []
        #         }
        #       end
        #     }
        #   end
        # end

        def prod_object
          @prod_object ||= Product.unscoped.find_by(id: object[:id], is_deleted: false)
        end

        def warehouse
          @warehouse ||= object[:warehouse]
        end

        def product_category
          ShopothWarehouse::V1::Entities::CategoriesShortInfoTree.represent(prod_object&.leaf_category)
        end

        def product_features_attributes
          ShopothWarehouse::V1::Entities::ProductFeatures.represent(prod_object.product_features)
        end

        def attribute_value_images
          prod_object.attribute_value_images
        end

        def meta_info
          ShopothWarehouse::V1::Entities::MetaData.represent(prod_object.meta_datum)
        end

        def created_by
          return {} if warehouse&.warehouse_type == Warehouse::WAREHOUSE_TYPES[:distribution]

          {
            id: prod_object.created_by_id,
            name: Staff.unscoped.find_by(id: prod_object.created_by_id)&.name,
          }
        end
      end
    end
  end
end
