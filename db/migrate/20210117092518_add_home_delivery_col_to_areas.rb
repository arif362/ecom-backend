class AddHomeDeliveryColToAreas < ActiveRecord::Migration[6.0]
  def change
    add_column :areas, :home_delivery, :boolean, default: false
  end
end
