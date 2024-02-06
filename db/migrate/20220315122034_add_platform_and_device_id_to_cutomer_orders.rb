class AddPlatformAndDeviceIdToCutomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_orders, :platform, :string
    add_column :customer_orders, :device_info_id, :bigint
  end
end
