class CreateShopothVehicles < ActiveRecord::Migration[6.0]
  def change
    create_table :shopoth_vehicles do |t|
      t.string :vehicle_type
      t.string :bn_vehicle_type
      t.string :vehicle_number
      t.string :bn_vehicle_number
      t.string :company_name
      t.string :bn_company_name
      t.string :status
      t.string :bn_status
      t.string :validity
      t.string :bn_validity
      t.string :driver_name
      t.string :bn_driver_name
      t.timestamps
    end
  end
end
