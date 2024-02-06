class AddIsPercentageDiscountVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :variants, :is_percentage_discount, :boolean, default: true
  end
end
