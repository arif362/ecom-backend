module ShopothWarehouse
  module V1
    module NamedParams
      module Products
        extend ::Grape::API::Helpers

        params :create_product_params do
          requires :product, type: Hash do
            requires :title, type: String
            optional :bn_title, type: String, desc: 'Bangla title'
            optional :is_refundable, type: Boolean
            requires :slug, type: String
            optional :return_policy, type: String
            optional :bn_return_policy, type: String
            optional :is_trending, type: Boolean
            optional :is_daily_deals, type: Boolean
            optional :is_new_arrival, type: Boolean
            optional :is_best_selling, type: Boolean
            optional :description, type: String
            optional :bn_description, type: String, desc: 'Bangla description'
            optional :short_description, type: String
            optional :bn_short_description, type: String
            optional :warranty_type, type: String
            optional :warranty_period, type: String
            optional :warranty_policy, type: String
            optional :bn_warranty_policy, type: String
            optional :dangerous_goods, type: String
            optional :inside_box, type: String
            optional :bn_inside_box, type: String
            optional :video_url, type: String
            optional :sku_type, type: String
            optional :image, type: String
            optional :warranty_policy, type: String
            requires :company, type: String
            optional :bn_company, type: String
            requires :brand_id, type: String
            optional :certification, type: String
            optional :bn_certification, type: String
            optional :license_required, type: String
            optional :bn_license_required, type: String
            optional :material, type: String
            optional :bn_material, type: String
            optional :consumption_guidelines, type: String
            optional :bn_consumption_guidelines, type: String
            optional :temperature_requirement, type: String
            optional :bn_temperature_requirement, type: String
            optional :keywords, type: String
            optional :brand_message, type: String
            optional :tagline, type: String
            optional :public_visibility, type: Boolean
            requires :hero_image_file
            optional :images
            # this is actual Product Type, our associated Product type should be offer type
            requires :product_type, type: String
            optional :product_specifications
            optional :published, type: Boolean
            optional :max_quantity_per_order, type: Integer
            optional :weight, type: Integer, default: 0
            optional :is_emi_available, type: Boolean, default: false
            optional :tenures, type: Array, default: []
            optional :business_type, type: String, values: Product.business_types.keys
            optional :bundle_variants, type: Array do
              requires :bundle_sku, type: String
              optional :quantity, type: Integer
            end

            requires :variants_attributes, type: Array do
              requires :sku, type: String
              optional :weight, type: Float
              optional :height, type: Float
              optional :width, type: Float
              optional :depth, type: Float
              optional :weight_unit, type: String
              optional :height_unit, type: String
              optional :width_unit, type: String
              optional :depth_unit, type: String
              optional :primary, type: Boolean
              requires :price_consumer, type: Float
              optional :sku_case_dimension, type: String
              optional :sku_case_width, type: Float
              optional :sku_case_length, type: Float
              optional :sku_case_height, type: Float
              optional :sku_case_width_unit, type: String
              optional :sku_case_length_unit, type: String
              optional :sku_case_height_unit, type: String
              optional :case_weight_unit, type: String
              optional :case_weight, type: String
              optional :consumer_discount, type: Float
              optional :vat_tax, type: Float
              optional :discount_type, type: String
              optional :moq, type: Float
              optional :code_by_supplier, type: String
              optional :product_attribute_value_ids, type: Array
              optional :b2b_discount_type, type: String
              optional :b2b_price, type: Float
              optional :b2b_discount, type: Float
              optional :is_deleted, type: Boolean
            end
            optional :frequently_asked_questions_attributes, type: Array do
              requires :question, type: String
              optional :bn_question, type: String
              requires :answer, type: String
              optional :bn_answer, type: String
            end
            requires :category_ids, type: Array
            optional :product_type_ids, type: Array
            requires :leaf_category_id, type: Integer
            optional :product_attribute_images_attributes, type: Array do
              requires :product_attribute_value_id, type: Integer
              optional :is_default, type: Boolean
              optional :images_file, type: Array
            end
            optional :attribute_set_id, type: Integer
            optional :image_attribute_id, type: Integer
            optional :product_features_attributes, type: Array do
              requires :title, type: String
              requires :bn_title, type: String
              optional :description, type: String
              optional :bn_description, type: String
            end
            optional :meta_datum_attributes, type: Hash do
              optional :meta_keyword, type: Array
              optional :bn_meta_keyword, type: Array
              optional :meta_title, type: String
              optional :bn_meta_title, type: String
              optional :meta_description, type: String
              optional :bn_meta_description, type: String
            end
          end
        end

        params :update_product_params do
          requires :product, type: Hash do
            requires :title, type: String
            optional :bn_title, type: String, desc: 'Bangla title'
            optional :is_refundable, type: Boolean
            requires :slug, type: String
            optional :return_policy, type: String
            optional :bn_return_policy, type: String
            optional :is_trending, type: Boolean
            optional :is_daily_deals, type: Boolean
            optional :is_new_arrival, type: Boolean
            optional :is_best_selling, type: Boolean
            optional :description, type: String
            optional :bn_description, type: String, desc: 'Bangla description'
            optional :short_description, type: String
            optional :bn_short_description, type: String
            optional :warranty_type, type: String
            optional :warranty_period, type: String
            optional :warranty_policy, type: String
            optional :bn_warranty_policy, type: String
            optional :dangerous_goods, type: String
            optional :inside_box, type: String
            optional :bn_inside_box, type: String
            optional :video_url, type: String
            optional :sku_type, type: String
            optional :image, type: String
            optional :warranty_policy, type: String
            requires :company, type: String
            optional :bn_company, type: String
            requires :brand_id, type: String
            optional :certification, type: String
            optional :bn_certification, type: String
            optional :license_required, type: String
            optional :bn_license_required, type: String
            optional :material, type: String
            optional :bn_material, type: String
            optional :consumption_guidelines, type: String
            optional :bn_consumption_guidelines, type: String
            optional :temperature_requirement, type: String
            optional :bn_temperature_requirement, type: String
            optional :keywords, type: String
            optional :brand_message, type: String
            optional :tagline, type: String
            optional :public_visibility, type: Boolean
            optional :hero_image_file
            optional :images
            # this is actual Product Type, our associated Product type should be offer type
            requires :product_type, type: String
            optional :product_specifications
            optional :published, type: Boolean
            optional :max_quantity_per_order, type: Integer
            optional :weight, type: Integer, default: 0
            optional :is_emi_available, type: Boolean, default: false
            optional :tenures, type: Array, default: []
            optional :business_type, type: String, values: Product.business_types.keys
            optional :bundle_variants, type: Array do
              requires :bundle_sku, type: String
              optional :quantity, type: Integer
            end

            requires :variants_attributes, type: Array do
              requires :sku, type: String
              optional :weight, type: Float
              optional :height, type: Float
              optional :width, type: Float
              optional :depth, type: Float
              optional :weight_unit, type: String
              optional :height_unit, type: String
              optional :width_unit, type: String
              optional :depth_unit, type: String
              optional :primary, type: Boolean
              optional :price_consumer, type: Float
              optional :sku_case_dimension, type: String
              optional :sku_case_width, type: Float
              optional :sku_case_length, type: Float
              optional :sku_case_height, type: Float
              optional :sku_case_width_unit, type: String
              optional :sku_case_length_unit, type: String
              optional :sku_case_height_unit, type: String
              optional :case_weight_unit, type: String
              optional :case_weight, type: String
              optional :consumer_discount, type: Float
              optional :vat_tax, type: Float
              optional :discount_type, type: String
              optional :moq, type: Float
              optional :code_by_supplier, type: String
              optional :product_attribute_value_ids, type: Array
              optional :b2b_discount_type, type: String
              optional :b2b_price, type: Float
              optional :b2b_discount, type: Float
              optional :is_deleted, type: Boolean
            end
            optional :frequently_asked_questions_attributes, type: Array do
              requires :question, type: String
              optional :bn_question, type: String
              requires :answer, type: String
              optional :bn_answer, type: String
            end
            optional :category_ids, type: Array
            optional :product_type_ids, type: Array
            optional :leaf_category_id, type: Integer
            optional :product_attribute_images_attributes, type: Array do
              requires :product_attribute_value_id, type: Integer
              optional :is_default, type: Boolean
              optional :images_file, type: Array
            end
            optional :attribute_set_id, type: Integer
            optional :image_attribute_id, type: Integer
            optional :product_features_attributes, type: Array do
              requires :title, type: String
              requires :bn_title, type: String
              optional :description, type: String
              optional :bn_description, type: String
            end
            optional :meta_datum_attributes, type: Hash do
              optional :meta_keyword, type: Array
              optional :bn_meta_keyword, type: Array
              optional :meta_title, type: String
              optional :bn_meta_title, type: String
              optional :meta_description, type: String
              optional :bn_meta_description, type: String
            end
          end
        end

        params :unique_slug_check_params do
          requires :slug, type: String, allow_blank: false
          optional :id, type: Integer
        end

        params :get_all_deleted_products_params do
          use :pagination, per_page: 50
        end

        params :first_10_products_based_on_title_params do
          requires :title, type: String
        end

        params :search_for_assigning_products_into_supplier_variant_params do
          requires :type, type: Integer
          requires :search_string, type: String
        end

        params :bulk_upload_temporary_image_params do
          requires :bulk_upload_tmp_image, type: Hash do
            requires :file_name, type: String
            requires :image_file
          end
        end

        params :delete_a_specific_bulk_image_params do
          requires :image_id
        end

        params :delete_a_specific_product_image_params do
          requires :product_id, type: Integer
        end

        params :list_of_product_params do
          use :pagination, per_page: 50
          optional :business_type, type: String, values: Product.business_types.keys
        end

        params :product_details_params do
          requires :id, type: String, allow_blank: false, desc: 'Product id'
        end

        params :category_changes_log_params do
          use :pagination, per_page: 50
        end
      end
    end
  end
end
