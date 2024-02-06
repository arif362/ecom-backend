class AddDiscountTypeVariants < ActiveRecord::Migration[6.0]
  def change
    remove_column :variants, :is_percentage_discount, :boolean
    add_column :variants, :discount_type, :integer, default: 0
  end
end
