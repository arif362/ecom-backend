class AddColToRoute < ActiveRecord::Migration[6.0]
  def change
    add_column :routes, :cash_amount, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :routes, :digital_amount, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
