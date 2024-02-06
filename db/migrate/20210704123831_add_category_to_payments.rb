class AddCategoryToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :category, :integer
  end
end
