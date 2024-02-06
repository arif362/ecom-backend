class AddProductColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :short_description, :text
    add_column :products, :bn_short_description, :text
    add_column :products, :warranty_type, :string
    add_column :products, :warranty_period, :string
    add_column :products, :warranty_policy, :text
    add_column :products, :bn_warranty_policy, :text
    add_column :products, :dangerous_goods, :string
    add_column :products, :inside_box, :text
    add_column :products, :bn_inside_box, :text
    add_column :products, :package_weight, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :products, :package_height, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :products, :package_width, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :products, :package_length, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :products, :video_url, :string
    add_column :products, :sku_type, :string
    add_column :products, :sku_quantity, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :products, :sku_consumer, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :products, :sku_retailer_price, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :products, :sku_distributor_price, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
