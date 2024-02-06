class RemoveIsEmiAppliedColumnFromCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    remove_column :customer_orders, :is_emi_applied, :boolean
  end
end
