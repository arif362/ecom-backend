# frozen_string_literal: true

module ProductCategoryList
  extend ActiveSupport::Concern
  included do
    PRODUCT_TYPES = {
      trending: 'trending',
      bestselling: 'best-selling',
      new_arrival: 'new-arrival',
      daily_deals: 'daily-deals',
      private_label: 'private-label',
      featured: 'featured',
      bundles: 'bundles',
    }.freeze

    scope :search_by_title, ->(title) { where('lower(title) = ?', title.downcase) || where(bn_title: title) }

    def self.get_product_list_by_product_type_for_b2c(slug, warehouse_id = nil)
      product_type = ProductType.find_by(slug: slug)
      products = Product.publicly_visible
                   .b2c_products
                   .joins(:product_types)
                   .where(product_types: { slug: slug })
                   .includes(:product_types, :brand, :variants, main_image_attachment: :blob)
      product_list = Product.order_by_weight_and_available_quantity(products, warehouse_id).uniq.first(11)
      {
        title: product_type&.title,
        slug: product_type&.slug,
        bn_title: product_type&.bn_title,
        product_list: product_list,
      }
    end

    def self.order_by_weight_and_available_quantity(products, warehouse_id = nil, product_type = nil)
      products = if warehouse_id.present?
                   products.joins(variants: :warehouse_variants).order(
                     "CASE
                       WHEN warehouse_variants.available_quantity > 0 AND warehouse_variants.warehouse_id = #{warehouse_id} THEN 1
                       ELSE 2
                     END",
                   )
                 else
                   products.joins(variants: :warehouse_variants).order(
                     "CASE
                       WHEN warehouse_variants.available_quantity > 0 THEN 1
                       ELSE 2
                     END",
                   )
                 end

      if product_type == 'best-selling'
        products.order(sell_count: :desc)
      else
        products.sort_by { |a| -a[:weight] }
      end
    end

    def self.fetch_flash_sales
      products ||= []
      flash_promo = Promotion.flash_sale.active.flash_unexpired.first
      return unless flash_promo.present?

      products = Product.publicly_visible.b2c_products.where(id: flash_promo.variants.map(&:product_id).uniq)
      { flash_sale: flash_promo, products: products.includes(:brand, :variants) }
    end

    def self.min_max_price(warehouse, products)
      price_range = { min_price: 0, max_price: 100 }
      variants ||= fetch_available_variants(warehouse, products)
      price_range[:min_price] = variants.minimum('variants.effective_mrp') || 0
      price_range[:max_price] = variants.maximum('variants.effective_mrp') || 100
      price_range
    end

    def self.fetch_available_variants(warehouse, products)
      if warehouse.present?
        products.joins(variants: :warehouse_variants).
          where('warehouse_variants.available_quantity > ? AND warehouse_variants.warehouse_id = ?',
                0, warehouse.id)
      else
        products.joins(:variants)
      end
    end

    def attributes_wise_products(attributes)
      joins(:product_attribute_values).
        where(product_attribute_values: { id: attributes })
    end

    private_class_method :fetch_available_variants
  end
end
