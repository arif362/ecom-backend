class ProductAttributeValuesVariant < ApplicationRecord
  belongs_to :variant
  belongs_to :product_attribute_value

  default_scope { where(is_deleted: false) }
end
