class AddQcStatusColToReturnCustomerOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :return_customer_orders, :qc_status, :integer
  end
end
