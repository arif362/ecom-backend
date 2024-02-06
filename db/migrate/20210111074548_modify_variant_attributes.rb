class ModifyVariantAttributes < ActiveRecord::Migration[6.0]
  def change
    change_column_null :variants, :price_distribution, null: true
    change_column_null :variants, :price_retailer, null: true
    change_column_null :variants, :sku_case_dimension, null: true
    change_column_null :variants, :vat_tax, null: true
    change_column_null :variants, :moq, null: true
  end
end
