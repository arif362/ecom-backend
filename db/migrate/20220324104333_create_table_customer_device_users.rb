class CreateTableCustomerDeviceUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :customer_device_users do |t|
      t.bigint "customer_device_id", null: false
      t.bigint "user_id", null: false
      t.timestamps
    end
  end
end
