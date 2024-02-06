class AddWarehouseReferenceToCustomerOrder < ActiveRecord::Migration[6.0]
  def change
    add_reference :customer_orders, :warehouse, index: true, foreign_key: true
  end
end
