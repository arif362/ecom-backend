class ChangeDeviceInfoToCustomerDevice < ActiveRecord::Migration[6.0]
  def change
    rename_table :device_infos, :customer_devices
  end
end
