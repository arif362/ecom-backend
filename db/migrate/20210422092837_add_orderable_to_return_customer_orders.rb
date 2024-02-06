class AddOrderableToReturnCustomerOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :return_customer_orders, :return_orderable_id, :integer
    add_column :return_customer_orders, :return_orderable_type, :string
  end
end
