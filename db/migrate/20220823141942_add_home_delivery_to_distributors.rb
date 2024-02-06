class AddHomeDeliveryToDistributors < ActiveRecord::Migration[6.0]
  def change
    add_column :distributors, :home_delivery, :boolean, default: false
  end
end
