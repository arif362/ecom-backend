class AddColumnsToVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :variants, :weight_unit, :string
    add_column :variants, :height_unit, :string
    add_column :variants, :width_unit, :string
    add_column :variants, :depth_unit, :string
    add_column :variants, :sku_case_width_unit, :string
    add_column :variants, :sku_case_length_unit, :string
    add_column :variants, :sku_case_height_unit, :string
    add_column :variants, :case_weight_unit, :string
  end
end
