class RemoveAddressColumnFromWarehouses < ActiveRecord::Migration[6.0]
  def change
    remove_column :warehouses, :address, :string
  end
end
