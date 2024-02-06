class CreateOrderStatus < ActiveRecord::Migration[6.0]
  def change
    create_table :order_statuses do |t|
      t.integer :type, default: 0
      t.string :system_order_status, default: ''
      t.string :customer_order_status, default: ''
      t.string :admin_order_status, default: ''
      t.string :sales_representative_order_status, default: ''
      t.string :partner_order_status, default: ''
    end
  end
end
