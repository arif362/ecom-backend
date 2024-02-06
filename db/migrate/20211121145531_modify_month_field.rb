class ModifyMonthField < ActiveRecord::Migration[6.0]
  def change
    remove_column :month_wise_payment_histories, :month, :integer
    remove_column :month_wise_payment_histories, :year, :integer
    add_column :month_wise_payment_histories, :month, :string
  end
end
