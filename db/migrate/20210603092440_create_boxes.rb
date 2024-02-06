class CreateBoxes < ActiveRecord::Migration[6.0]
  def change
    create_table :boxes do |t|
      t.references :dh_purchase_order, foreign_key: true, null: false
      t.timestamps
    end
  end
end
