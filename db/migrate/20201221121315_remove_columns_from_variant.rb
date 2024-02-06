class RemoveColumnsFromVariant < ActiveRecord::Migration[6.0]
  def up
    remove_columns :variants, :price_supplier
    remove_columns :variants, :sku_code
    remove_columns :variants, :bn_sku_code
    remove_columns :variants, :bn_sku
    remove_columns :variants, :sku_case
    remove_columns :variants, :bn_sku_case
    remove_columns :variants, :bn_sku_dimension
    remove_columns :variants, :bn_case_weight
    remove_columns :variants, :sku_dimension
    remove_columns :variants, :bn_sku_case_dimension
    remove_columns :variants, :product_size
    remove_columns :variants, :bn_product_size
    remove_columns :variants, :sku_weight
    remove_columns :variants, :bn_sku_weight
    remove_columns :variants, :bn_price_distributor
    remove_columns :variants, :price_retail
    remove_columns :variants, :mrp
    remove_columns :variants, :profit
    remove_columns :variants, :margin
  end

  def down
    add_column :variants, :price_supplier, :decimal
    add_column :variants, :sku_code, :string
    add_column :variants, :bn_sku_code, :string
    add_column :variants, :bn_sku, :string
    add_column :variants, :sku_case, :string
    add_column :variants, :bn_sku_case, :string
    add_column :variants, :bn_sku_dimension, :decimal
    add_column :variants, :bn_case_weight, :decimal
    add_column :variants, :sku_dimension, :decimal
    add_column :variants, :bn_sku_case_dimension, :string
    add_column :variants, :product_size, :string
    add_column :variants, :bn_product_size, :string
    add_column :variants, :sku_weight, :decimal
    add_column :variants, :bn_sku_weight, :decimal
    add_column :variants, :bn_price_distributor, :decimal
    add_column :variants, :price_retail, :decimal
    add_column :variants, :mrp, :decimal
    add_column :variants, :profit, :decimal
    add_column :variants, :margin, :decimal
  end
end
