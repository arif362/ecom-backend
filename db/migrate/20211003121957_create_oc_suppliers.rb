class CreateOcSuppliers < ActiveRecord::Migration[6.0]
  def change
    create_table :oc_suppliers do |t|
      t.string :name
      t.timestamps
    end
  end
end
