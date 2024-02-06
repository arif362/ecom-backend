class AddAttributesToVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :variants, :sku_code, :string, null: false, default: ""
    add_column :variants, :bn_sku_code, :string, null: false, default: ""
    add_column :variants, :bn_sku, :string, null: false, default: ""
    add_column :variants, :sku_case, :string, null: false, default: ""
    add_column :variants, :bn_sku_case, :string, null: false, default: ""
    add_column :variants, :sku_case_dimension, :string, null: false, default: ""
    add_column :variants, :bn_sku_case_dimension, :string, null: false, default: ""
    add_column :variants, :case_weight, :string, null: false, default: ""
    add_column :variants, :bn_case_weight, :string, null: false, default: ""
    add_column :variants, :sku_dimension, :string, null: false, default: ""
    add_column :variants, :bn_sku_dimension, :string, null: false, default: ""
    add_column :variants, :product_size, :string, null: false, default: ""
    add_column :variants, :bn_product_size, :string, null: false, default: ""
    add_column :variants, :sku_weight, :string, null: false, default: ""
    add_column :variants, :bn_sku_weight, :string, null: false, default: ""
    add_column :variants, :bn_price_distributor, :decimal, precision: 10, scale: 2, null: false, default: 0.0
    add_column :variants, :price_agami_trade, :decimal, precision: 10, scale: 2, null: false, default: 0.0
    add_column :variants, :price_retail, :decimal, precision: 10, scale: 2, null: false, default: 0.0
    add_column :variants, :mrp, :decimal, precision: 10, scale: 2, null: false, default: 0.0
    add_column :variants, :consumer_discount, :decimal, precision: 10, scale: 2
    add_column :variants, :vat_tax, :decimal, precision: 10, scale: 2, null: false, default: 0.0
    add_column :variants, :effective_mrp, :decimal, precision: 10, scale: 2, null: false, default: 0.0
    add_column :variants, :profit, :decimal, precision: 10, scale: 2, null: false, default: 0.0
    add_column :variants, :margin, :decimal, precision: 10, scale: 2, null: false, default: 0.0
    add_column :variants, :moq, :decimal, precision: 10, scale: 2, null: false, default: 0.0
  end
end
