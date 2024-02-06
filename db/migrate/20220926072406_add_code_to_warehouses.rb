class AddCodeToWarehouses < ActiveRecord::Migration[6.0]
  def change
    add_column :warehouses, :code, :string
  end
end
