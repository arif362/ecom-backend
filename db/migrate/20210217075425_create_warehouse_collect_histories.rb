class CreateWarehouseCollectHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :warehouse_collect_histories do |t|
      t.integer :warehouse_id
      t.decimal :cash, default: 0.0
      t.decimal :wallet, default: 0.0
      t.integer :return, default: 0
      t.date :collect_date

      t.timestamps
    end
  end
end
