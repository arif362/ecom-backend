class AddAttributesToPermissions < ActiveRecord::Migration[6.0]
  def change
    add_column :permissions, :staff_id, :integer
    add_column :permissions, :resource_name, :string
    add_column :permissions, :list_permission?, :boolean, default: false
    add_column :permissions, :create_permission?, :boolean, default: false
    add_column :permissions, :edit_permission?, :boolean, default: false
    add_column :permissions, :delete_permission?, :boolean, default: false
    remove_column :permissions, :admin_user_id, :integer
    remove_column :permissions, :product_manager, :boolean
    remove_column :permissions, :suplier_manager, :boolean
  end
end
