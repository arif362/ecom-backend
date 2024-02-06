class AddHomeDeliveryToThana < ActiveRecord::Migration[6.0]
  def change
    add_column :thanas, :home_delivery, :boolean, default: false
  end
end
