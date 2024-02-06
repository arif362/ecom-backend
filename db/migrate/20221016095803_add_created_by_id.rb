class AddCreatedById < ActiveRecord::Migration[6.0]
  def change
    add_column :wh_purchase_orders, :created_by_id, :integer
    add_column :dh_purchase_orders, :created_by_id, :integer
    add_column :products, :created_by_id, :integer
    add_column :brands, :created_by_id, :integer
    add_column :variants, :created_by_id, :integer
    add_column :return_transfer_orders, :created_by_id, :integer
    add_column :promotions, :created_by_id, :integer
    add_column :suppliers, :created_by_id, :integer
    add_column :suppliers_variants, :created_by_id, :integer
    add_column :categories, :created_by_id, :integer
  end
end
