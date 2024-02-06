class CreateReturnChallans < ActiveRecord::Migration[6.0]
  def change
    create_table :return_challans do |t|
      t.bigint :warehouse_id, null: false
      t.bigint :distributor_id, null: false
      t.integer :status, null: false, default: 0
      t.bigint :created_by_id
      t.timestamps
    end
  end
end
