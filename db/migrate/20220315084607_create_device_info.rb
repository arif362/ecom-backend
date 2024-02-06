class CreateDeviceInfo < ActiveRecord::Migration[6.0]
  def change
    create_table :device_infos do |t|
      t.string :device_id
      t.string :device_model
      t.string :device_os_type
      t.string :device_os_version
      t.string :email
      t.string :phone
      t.integer :user_id
      t.string :app_version
      t.string :app_language
      t.string :fcm_id
      t.string :ip
      t.string :brand
      t.string :imei

      t.timestamps
    end
  end
end
