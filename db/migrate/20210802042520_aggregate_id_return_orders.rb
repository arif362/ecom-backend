class AggregateIdReturnOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :return_customer_orders, :aggregate_return_id, :integer
    remove_column :return_customer_orders, :grand_total, :decimal
    remove_column :return_customer_orders, :coupon_id, :string
  end
end
