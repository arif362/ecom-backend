if suppliers_variants.present?
  json.suppliers_variants do
    json.array! suppliers_variants do |suppliers_variant|
      json.supplier_price suppliers_variant.supplier_price
      json.variant_sku suppliers_variant.variant.sku
      json.product_title suppliers_variant.variant.product.title
    end
  end
end
