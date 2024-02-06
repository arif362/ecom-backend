class AddBusinessTypeOnCart < ActiveRecord::Migration[6.0]
  def change
    add_column :carts, :business_type, :integer, default: 0
  end
end
