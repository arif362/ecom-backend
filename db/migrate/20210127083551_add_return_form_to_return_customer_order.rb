class AddReturnFormToReturnCustomerOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :return_customer_orders, :form_of_return, :integer, default: 0
  end
end
