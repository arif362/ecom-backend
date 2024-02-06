class CreateFailedQcs < ActiveRecord::Migration[6.0]
  def change
    create_table :failed_qcs do |t|
      t.integer :variant_id, null: false
      t.integer :quantity, null: false
      t.string :questions, array: true, default: []
      t.references :failable, polymorphic: true
      t.timestamps
    end
  end
end
