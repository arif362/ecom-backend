class CreateRouteDevices < ActiveRecord::Migration[6.0]
  def change
    create_table :route_devices do |t|
      t.string :device_id, null: false
      t.string :password_hash
      t.integer :route_id
      t.string :unique_id, null: false
      t.timestamps
    end
  end
end
