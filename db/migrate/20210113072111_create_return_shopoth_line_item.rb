class CreateReturnShopothLineItem < ActiveRecord::Migration[6.0]
  def change
    create_table :return_shopoth_line_items do |t|
      t.references :return_order, null: false, foreign_key: true
      t.references :shopoth_line_item, null: false, foreign_key: true
      t.integer :quantity, default: 1

      t.timestamps
    end
  end
end
