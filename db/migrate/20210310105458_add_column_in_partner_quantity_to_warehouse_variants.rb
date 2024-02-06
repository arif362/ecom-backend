class AddColumnInPartnerQuantityToWarehouseVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :warehouse_variants, :in_partner_quantity, :integer, default: 0
  end
end
