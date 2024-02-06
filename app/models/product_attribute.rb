class ProductAttribute < ApplicationRecord
  audited
  has_many :product_attribute_values, dependent: :destroy
  has_many :product_attribute_values_variants, through: :product_attribute_values
  has_many :product_attribute_images, through: :product_attribute_values
  has_many :attribute_set_product_attributes
  has_many :attribute_sets, through: :attribute_set_product_attributes

  accepts_nested_attributes_for :product_attribute_values, reject_if: :all_blank, allow_destroy: true, update_only: true

  validates :name, :unique_id, uniqueness: true
  before_create :assign_unique_id, :call_3ps_create_api

  default_scope { order('id DESC') }
  default_scope { where(is_deleted: false) }

  def variants_uniq_attr_values(products)
    values = product_attribute_values_variants.where(variant_id: Variant.get_variants(products).ids).uniq(&:product_attribute_value_id)
    values&.map do |value|
      {
        id: value.product_attribute_value_id,
        value: value.product_attribute_value.value,
        bn_value: value.product_attribute_value.bn_value,
      }
    end
  end

  def assign_unique_id
    self.unique_id = SecureRandom.uuid
  end

  def call_3ps_create_api
    response = Thanos::ProductAttribute.create(self)
    return unless response[:error].present?

    e = errors.add(:base, (response[:error_descrip]).to_s)
    fail StandardError, e.to_s
  end
end
