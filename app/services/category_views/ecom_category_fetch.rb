module CategoryViews
  class EcomCategoryFetch
    include Interactor

    delegate :category,
             :category_details,
             :price_range,
             :request_source,
             :brands,
             to: :context

    def call
      products = take_products
      minimum_product_price = products.joins(:variants).minimum('variants.effective_mrp') || 0
      maximum_product_price = products.joins(:variants).maximum('variants.effective_mrp') || 100
      context.price_range = { min_price: minimum_product_price, max_price: maximum_product_price }

      brands = Brand.where(id: products.pluck(:brand_id).compact.uniq)
      context.brands = Ecommerce::V1::Entities::BrandShortInfos.represent(brands)

      context.attributes = AttributeSetProductAttribute.get_attributes_and_values(products)
      context.category_details = Ecommerce::V1::Entities::Categories.represent(category, request_source: request_source)
    end

    private

    def take_products
      category.products&.publicly_visible&.includes(:brand, :variants, :product_types, main_image_attachment: :blob)
    end
  end
end
