class AddIndexToWarehouseCollectHistory < ActiveRecord::Migration[6.0]
  def change
    add_index(:warehouse_collect_histories, [:warehouse_id, :collect_date], unique: true, name: 'warehouse_date_index')
  end
end
