class AddProductWarrantyPeriodType < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :warranty_period_type, :integer
  end
end
