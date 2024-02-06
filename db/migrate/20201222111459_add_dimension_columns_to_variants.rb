class AddDimensionColumnsToVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :variants, :sku_case_width, :decimal, precision: 10, scale: 2
    add_column :variants, :sku_case_length, :decimal, precision: 10, scale: 2
    add_column :variants, :sku_case_height, :decimal, precision: 10, scale: 2
  end
end

