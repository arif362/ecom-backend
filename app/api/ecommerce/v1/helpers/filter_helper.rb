# frozen_string_literal: true
module Ecommerce::V1::Helpers
  module FilterHelper
    extend Grape::API::Helpers

    def filter_by_price(category, min_price, max_price)
      min_price = min_price.to_f.floor
      max_price = max_price.to_f.ceil
      # Filtering on a price range, price coming from Variant model
      filtered = category.products.includes(:variants).where(
        "variants.price_consumer": min_price..max_price
      )
    end
    # TODO: improve performance later when things are stable
    def get_filter_options(products)
      filter = {}
      filter[:categories] = get_all_category
      filter[:attributes] = {}
      products.each do |p|
        # TODO: do not know why I have to get product_attribute_images to get product attribute
        # TODO: Warehouse team should fix this association and make changes here in future
        product_attrs = ProductAttribute.joins(product_attribute_values: {variants: :product}).where('products.id=?', p.id)
        product_attrs.each do |attr|
          if filter[:attributes].key?(attr.name)
            filter[:attributes][attr.name] = get_attributes_values(
              attr.product_attribute_values,
              attr,
              filter[:attributes][attr.name]
            )
          else
            filter[:attributes][attr.name] = {}
            filter[:attributes][attr.name] = get_attributes_values(
              attr.product_attribute_values,
              attr,
              filter[:attributes][attr.name]
            )
          end
        end
      end
      filter
    end
    # TODO: improve performance later when things are stable
    def get_all_category
      result = []
      categories = Category.where(parent_id: nil).where(home_page_visibility: true)
      categories.each do |c|
        result.append({ id: c.id, name: c.title })
      end
      result
    end

    def get_attributes_values(product_attr_vals, attr, already_added_hash)
      product_attr_vals.each do |p_attr_vals|
        already_added_hash[p_attr_vals.id] = {
          product_attribute_id: attr.id,
          product_attribute_name: attr.name,
          product_attribute_value_id: p_attr_vals.id,
          value: p_attr_vals.value,
          bn_value: p_attr_vals.bn_value
        }
      end
      already_added_hash
    end

    def apply_filter(params, products)
      if params[:product_attributes_id].present? && params[:product_attribute_value_ids].present?
        products = products.joins(variants: :product_attribute_values).where(
          'product_attribute_values.id IN (?) AND product_attribute_values.product_attribute_id IN (?)',
          params[:product_attribute_value_ids], params[:product_attribute_ids]
        )
      end
      if params[:max_price].present? && params[:min_price].present?
        min_price = params[:min_price]
        max_price = params[:max_price]
        products = products.joins(:variants).where('variants.price_consumer > ? AND variants.price_consumer <= ?', min_price, max_price)
      end
      products
    end
  end
end
