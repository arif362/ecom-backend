class AddColToReturnOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :return_orders, :delivered_to_sr_at, :datetime
    add_column :return_orders, :created_at, :datetime
    add_column :return_orders, :updated_at, :datetime
  end
end
