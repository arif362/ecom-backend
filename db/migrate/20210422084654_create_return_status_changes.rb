class CreateReturnStatusChanges < ActiveRecord::Migration[6.0]
  def change
    create_table :return_status_changes do |t|
      t.references :return_customer_order, null: false, foreign_key: true
      t.string :status
      t.string :changeable_type
      t.integer :changeable_id
      t.timestamps
    end
  end
end
