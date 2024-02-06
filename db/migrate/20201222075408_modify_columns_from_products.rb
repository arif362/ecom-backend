class ModifyColumnsFromProducts < ActiveRecord::Migration[6.0]
  def up
    remove_columns :products, :quantity
    remove_columns :products, :availability
    remove_columns :products, :promotional
    remove_columns :products, :discount
    remove_columns :products, :configuration
    remove_columns :products, :package_weight
    remove_columns :products, :package_height
    remove_columns :products, :package_width
    remove_columns :products, :package_length
    remove_columns :products, :sku_quantity
    remove_columns :products, :sku_consumer
    remove_columns :products, :sku_retailer_price
    remove_columns :products, :sku_distributor_price
    remove_columns :products, :uid
    remove_columns :products, :bn_uid
    remove_columns :products, :source
    remove_columns :products, :bn_source
    remove_columns :products, :bn_license_required
    remove_columns :products, :company_category
    remove_columns :products, :po_name
    remove_columns :products, :bn_po_name
    remove_columns :products, :product
    remove_columns :products, :bn_product
    remove_columns :products, :product_variant
    remove_columns :products, :broad_description
    remove_columns :products, :details
    remove_columns :products, :bn_details
    remove_columns :products, :additional_information
    remove_columns :products, :bn_additional_information
    remove_columns :products, :fragility
    remove_columns :products, :bn_fragility
    remove_columns :products, :segment
    remove_columns :products, :specific_product_lead_time
    remove_columns :products, :avaialability
  end

  def down
    add_column :products, :quantity, :string
    add_column :products, :availability, :boolean
    add_column :products, :promotional, :boolean
    add_column :products, :discount, :decimal
    add_column :products, :configuration, :text
    add_column :products, :package_weight, :decimal
    add_column :products, :package_height, :decimal
    add_column :products, :package_width, :decimal
    add_column :products, :package_length, :decimal
    add_column :products, :sku_quantity, :decimal
    add_column :products, :sku_consumer, :integer
    add_column :products, :sku_retailer_price, :decimal
    add_column :products, :sku_distributor_price, :decimal
    add_column :products, :bn_meta_keyword, :string
    add_column :products, :uid, :string
    add_column :products, :bn_uid, :string
    add_column :products, :source, :string
    add_column :products, :bn_source, :string
    add_column :products, :bn_license_required, :string
    add_column :products, :company_category, :string
    add_column :products, :po_name, :string
    add_column :products, :bn_po_name, :string
    add_column :products, :product, :string
    add_column :products, :bn_product, :string
    add_column :products, :product_variant, :string
    add_column :products, :broad_description, :text
    add_column :products, :details, :text
    add_column :products, :bn_details, :text
    add_column :products, :additional_information, :text
    add_column :products, :bn_additional_information, :string
    add_column :products, :fragility, :boolean
    add_column :products, :bn_fragility, :string
    add_column :products, :segment, :string
    add_column :products, :specific_product_lead_time, :datetime
    add_column :products, :avaialability, :boolean
  end
end
