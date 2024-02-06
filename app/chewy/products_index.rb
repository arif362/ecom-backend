class ProductsIndex < Chewy::Index
  index_scope Product.includes(:variants, :brand, :products_product_types, :product_types)
  field :title
  field :bn_title
  field :slug
  field :sku_type
  field :mini_img, value: ->(product) { product.master_img('mini') }
  field :image_url, value: ->(product) { product.master_img('product') }
  field :view_url, value: ->(product) { "/products/details/#{product.id}" }
  field :price, type: 'integer', value: ->(product) { product.get_product_base_price.to_i }
  field :discount, type: 'float', value: ->(product) { product.discount }
  field :effective_mrp, type: 'integer', value: ->(product) { product.discounted_price.to_i }
  field :brand_id, type: 'integer', value: ->(product) { product&.brand&.id }
  field :brand_name, value: ->(product) { product&.brand&.name }
  field :brand_name_bn, value: ->(product) { product&.brand&.bn_name }
  field :variant_id, type: 'integer', value: ->(product) { product&.min_emrp_variant&.id }
  field :badge, value: ->(product) { product&.promo_tag }
  field :sell_count, type: 'integer'
end
