class RemoveUnneccessaryColumnFromDb < ActiveRecord::Migration[6.0]
  def change
    remove_column :warehouse_variants, :bundle_quantity

    remove_column :line_items, :qr_code_initials
    remove_column :line_items, :qr_code_variant_quantity_start
    remove_column :line_items, :qr_code_variant_quantity_end

    remove_column :dh_purchase_orders, :status
    remove_column :dh_purchase_orders, :bn_status

    remove_column :wh_purchase_orders, :status
    remove_column :wh_purchase_orders, :bn_status
  end
end
