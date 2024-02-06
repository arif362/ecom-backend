class AddColumnsToProductAndCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :variants, :business_type, :integer, default: 0
    add_column :variants, :b2b_price, :decimal, precision: 10, scale: 2
    add_column :variants, :b2b_discount, :decimal, precision: 10, scale: 2, default: 0.00
    add_column :variants, :b2b_discount_type, :integer, default: 0

    add_column :categories, :business_type, :integer, default: 0

    add_column :customer_orders, :business_type, :integer, default: 0
  end
end
