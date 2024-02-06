class AddColumnsToPromotionVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :promotion_variants, :promotional_price, :decimal, precision: 10, scale: 2, default: '0.0'
    add_column :promotion_variants, :promotional_discount, :decimal, precision: 10, scale: 2, default: '0.0'
    add_reference :promotion_variants, :product, index: true
  end
end
