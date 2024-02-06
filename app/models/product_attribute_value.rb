class ProductAttributeValue < ApplicationRecord
  belongs_to :product_attribute
  has_many :product_attribute_values_variants, dependent: :destroy
  has_many :variants, through: :product_attribute_values_variants
  has_many :product_attribute_images

  validates :unique_id, uniqueness: true

  default_scope { where(is_deleted: false) }
end
