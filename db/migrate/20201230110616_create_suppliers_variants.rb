class CreateSuppliersVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :suppliers_variants do |t|
      t.references :variant, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true
      t.decimal :supplier_price, precision: 10, scale: 2, default: 0.0

      t.timestamps
    end
  end
end
