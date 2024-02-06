class RefactorReturnCustomerOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :return_customer_orders, :coupon_id, :string
  end
end
