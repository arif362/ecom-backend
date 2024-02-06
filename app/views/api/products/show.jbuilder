# frozen_string_literal: true

if @error.blank?
  if product.present?
    json.id product.id
    json.title product.title
    json.description product.description
    json.bn_title product.bn_title
    json.bn_description product.bn_description
    json.is_deleted product.is_deleted
    json.short_description product.short_description
    json.bn_short_description product.bn_short_description
    json.warranty_period product.warranty_period
    json.warranty_policy product.warranty_policy
    json.bn_warranty_policy product.bn_warranty_policy
    json.inside_box product.inside_box
    json.bn_inside_box product.bn_inside_box
    json.video_url product.video_url
    json.warranty_type product.warranty_type
    json.dangerous_goods product.dangerous_goods
    json.sku_type product.sku_type
    json.warranty_period_type product.warranty_period_type
    json.company product.company
    json.bn_company product.bn_company
    json.brand product.brand
    json.bn_brand product.bn_brand
    json.certification product.certification
    json.bn_certification product.bn_certification
    json.license_required product.license_required
    json.material product.material
    json.bn_material product.bn_material
    json.bn_broad_description product.bn_broad_description
    json.consumption_guidelines product.consumption_guidelines
    json.bn_consumption_guidelines product.bn_consumption_guidelines
    json.temperature_requirement product.temperature_requirement
    json.bn_temperature_requirement product.bn_temperature_requirement
    json.keywords product.keywords
    json.brand_message product.brand_message
    json.tagline product.tagline
    json.title product.title
    json.product_types product.product_types
    json.hero_image image_path(product.hero_image)
    json.hero_image_variant_path image_variant_path(product.hero_image)
    json.images image_paths(product.images)
    json.product_type product.product_type
    json.variants product.variants do |variant|
      json.id variant.id
      json.sku variant.sku
      json.weight variant.weight
      json.height variant.height
      json.width variant.width
      json.depth variant.depth
      json.weight_unit variant.weight_unit
      json.height_unit variant.height_unit
      json.width_unit variant.width_unit
      json.depth_unit variant.depth_unit
      json.sku_case_width_unit variant.sku_case_width_unit
      json.sku_case_length_unit variant.sku_case_length_unit
      json.sku_case_height_unit variant.sku_case_height_unit
      json.case_weight_unit variant.case_weight_unit
      json.deleted_at variant.deleted_at
      json.product_id variant.product_id
      json.configuration variant.configuration
      json.is_deleted variant.is_deleted
      json.primary variant.primary
      json.price_distribution variant.price_distribution
      json.price_retailer variant.price_retailer
      json.price_consumer variant.price_consumer
      json.sku_case_dimension variant.sku_case_dimension
      json.case_weight variant.case_weight
      json.price_agami_trade variant.price_agami_trade
      json.consumer_discount variant.consumer_discount
      json.vat_tax variant.vat_tax
      json.effective_mrp variant.effective_mrp
      json.moq variant.moq
      json.sku_case_width variant.sku_case_width
      json.sku_case_length variant.sku_case_length
      json.sku_case_height variant.sku_case_height
      json.last_item_index variant.last_item_index
        json.product_attribute_values variant.product_attribute_values do |product_attribute_value|
        json.id product_attribute_value.id
        json.product_attribute_id product_attribute_value.product_attribute_id
        json.value product_attribute_value.value
        json.bn_value product_attribute_value.bn_value
        json.is_deleted product_attribute_value.is_deleted
        json.product_attribute do
          json.id product_attribute_value.product_attribute.id
          json.name product_attribute_value.product_attribute.name
          json.bn_name product_attribute_value.product_attribute.bn_name
        end
        json.product_attribute_images product.product_attribute_images do |product_attribute_image|
          if product_attribute_image.product_attribute_value_id == product_attribute_value.id && product.id == product_attribute_image.product_id
            json.id product_attribute_image.id
            json.product_id product_attribute_image.product_id
            json.image image_paths(product_attribute_image.images)
          end
        end
      end
    end
    json.frequently_asked_questions product.frequently_asked_questions do |faq|
      json.id faq.id
      json.question faq.question
      json.bn_question faq.bn_question
      json.answer faq.answer
      json.bn_answer faq.bn_answer
      json.product_id faq.product_id
    end
    json.categories product.categories do |category|
      json.id category.id
      json.title category.title
      json.description category.description
      json.bn_title category.bn_title
      json.bn_description category.bn_description
      json.home_page_visibility category.home_page_visibility
    end
    if product_attributes.present?
      json.attributes product_attributes
    end
  else
    json.data({})
  end
end
