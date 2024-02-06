class CreatePermissions < ActiveRecord::Migration[6.0]
  def change
    create_table :permissions do |t|
      t.boolean :all, default: false
      t.boolean :product_manager, default: false
      t.boolean :suplier_manager, default: false
      t.integer :admin_user_id

      t.timestamps
    end
  end
end
