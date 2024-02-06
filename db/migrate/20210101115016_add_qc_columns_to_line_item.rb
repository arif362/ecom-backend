class AddQcColumnsToLineItem < ActiveRecord::Migration[6.0]
  def change
    add_column :line_items, :qr_code_initials, :string
    add_column :line_items, :qr_code_variant_quantity_start, :integer
    add_column :line_items, :qr_code_variant_quantity_end, :integer
  end
end
