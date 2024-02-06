class AddColumnsToCoupons < ActiveRecord::Migration[6.0]
  def change
    add_column :coupons, :is_used, :boolean, default: false
    add_column :coupons, :is_deleted, :boolean, default: false
    add_column :coupons, :usable_id, :integer
    add_column :coupons, :usable_type, :string
    add_column :coupons, :promotion_id, :integer
    add_column :coupons, :customer_order_id, :integer
    add_column :coupons, :return_customer_order_id, :integer
    remove_column :coupons, :warehouse_id, :integer
    remove_column :coupons, :discount_type, :integer
    remove_column :coupons, :max_discount, :decimal
    remove_column :coupons, :status, :integer
    change_column_null :coupons, :discount_amount, true
  end
end