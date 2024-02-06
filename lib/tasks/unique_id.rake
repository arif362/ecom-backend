namespace :unique_ids do
  desc 'This task generates unique id'
  task generate_unique_id: :environment do |t, args|
    suppliers = Supplier.unscoped.where(unique_id: nil)
    suppliers.each do |supplier|
      supplier.update_columns(unique_id: SecureRandom.uuid)
    end
    categories = Category.unscoped.where(unique_id: nil)
    categories.each do |category|
      category.update_columns(unique_id: SecureRandom.uuid)
    end
    attribute_sets = AttributeSet.unscoped.where(unique_id: nil)
    attribute_sets.each do |attribute_set|
      attribute_set.update_columns(unique_id: SecureRandom.uuid)
    end
    product_attributes = ProductAttribute.unscoped.where(unique_id: nil)
    product_attributes.each do |product_attribute|
      product_attribute.update_columns(unique_id: SecureRandom.uuid)
    end
    product_attribute_values = ProductAttributeValue.unscoped.where(unique_id: nil)
    product_attribute_values.each do |product_attribute_value|
      product_attribute_value.update_columns(unique_id: SecureRandom.uuid)
    end
    brands = Brand.unscoped.where(unique_id: nil)
    brands.each do |brand|
      brand.update_columns(unique_id: SecureRandom.uuid)
    end
    products = Product.unscoped.where(unique_id: nil)
    products.each do |product|
      product.update_columns(unique_id: SecureRandom.uuid)
    end
    variants = Variant.unscoped.where(unique_id: nil)
    variants.each do |variant|
      variant.update_columns(unique_id: SecureRandom.uuid)
    end
    wh_purchase_orders = WhPurchaseOrder.unscoped.where(unique_id: nil)
    wh_purchase_orders.each do |wh_purchase_order|
      wh_purchase_order.update_columns(unique_id: SecureRandom.uuid)
    end
  rescue StandardError => error
    puts "Error updating #{error}"
  end
end
