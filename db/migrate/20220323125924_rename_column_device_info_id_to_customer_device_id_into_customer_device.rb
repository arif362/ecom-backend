class RenameColumnDeviceInfoIdToCustomerDeviceIdIntoCustomerDevice < ActiveRecord::Migration[6.0]
  def change
    rename_column :customer_orders, :device_info_id, :customer_device_id
  end
end
