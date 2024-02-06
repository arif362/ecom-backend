class CreateBundles < ActiveRecord::Migration[6.0]
  def change
    create_table :bundles do |t|
      t.integer :variant_id, null: false
      t.integer :status

      t.timestamps
    end
  end
end
