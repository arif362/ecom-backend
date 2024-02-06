# frozen_string_literal: true

if @error.blank?
  if product_attribute.present?
    json.id product_attribute.id
    json.name product_attribute.name
    json.bn_name product_attribute.bn_name
    json.product_attribute_values product_attribute.product_attribute_values do |product_attribute_value|
      if product_attribute_value.is_deleted.eql?(false)
        json.id product_attribute_value.id
        json.value product_attribute_value.value
        json.bn_value product_attribute_value.bn_value
        json.is_deleted product_attribute_value.is_deleted
      end
    end
  else
    json.data({})
  end
end
