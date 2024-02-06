class AttributeSetProductAttribute < ApplicationRecord
  belongs_to :attribute_set
  belongs_to :product_attribute

  def self.get_attributes_and_values(products)
    return [] unless products.present?

    attr_set_prod_attributes(products)&.map do |attribute_set_product_attr|
      product_attribute = attribute_set_product_attr.product_attribute
      next unless product_attribute.present?

      {
        id: product_attribute.id,
        name: product_attribute.name,
        bn_name: product_attribute.bn_name,
        values: product_attribute.variants_uniq_attr_values(products),
      }
    end
  end

  def self.attr_set_prod_attributes(products)
    AttributeSetProductAttribute.includes(:product_attribute).where(attribute_set_id: uniq_attribute_set_ids(products)).uniq(&:product_attribute_id)
  end

  def self.uniq_attribute_set_ids(products)
    products.pluck(:attribute_set_id).uniq.compact
  end
end
