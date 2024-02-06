class AddReasonToReturnOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :return_orders, :reason, :integer
  end
end
