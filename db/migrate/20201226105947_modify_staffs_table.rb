class ModifyStaffsTable < ActiveRecord::Migration[6.0]
  def up
    remove_column :staffs, :password_hash
    change_column_null :staffs, :address_line, true

    add_column :staffs, :encrypted_password, :string
  end

  def down
    add_column :staffs, :password_hash, :string
    remove_column :staffs, :encrypted_password
  end
end
