class AddEmailPasswordToWarehouses < ActiveRecord::Migration[6.0]
  def change
    add_column :warehouses, :email, :string
    add_column :warehouses, :password, :string
  end
end
