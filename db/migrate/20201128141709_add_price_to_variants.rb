class AddPriceToVariants < ActiveRecord::Migration[6.0]
  def change
    add_column :variants, :price_supplier, :decimal, precision: 10, scale: 2, null: false, default: 0.0
    add_column :variants, :price_distribution, :decimal, precision: 10, scale: 2, null: false, default: 0.0
    add_column :variants, :price_retailer, :decimal, precision: 10, scale: 2, null: false, default: 0.0
    add_column :variants, :price_consumer, :decimal, precision: 10, scale: 2, null: false, default: 0.0
  end
end
