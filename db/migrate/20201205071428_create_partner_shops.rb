class CreatePartnerShops < ActiveRecord::Migration[6.0]
  def change
    create_table :partner_shops do |t|
      t.integer :sales_representative_id, null: false
      t.string :day, null: false
      t.timestamps
    end
  end
end
