class CreateStaffs < ActiveRecord::Migration[6.0]
  def change
    create_table :staffs do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false, default: ""
      t.integer :staff_role_id
      t.string :password_hash, null: false, default: ""
      t.integer :warehouse_id
      t.timestamps
    end

    add_index :staffs, :email, unique: true
  end
end
