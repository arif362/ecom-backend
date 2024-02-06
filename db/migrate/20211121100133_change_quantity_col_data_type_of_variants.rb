class ChangeQuantityColDataTypeOfVariants < ActiveRecord::Migration[6.0]
  def change
    remove_column :variants, :quantity, :decimal
    add_column :variants, :quantity, :integer, default: 0
  end
end
