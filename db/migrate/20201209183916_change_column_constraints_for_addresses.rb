class ChangeColumnConstraintsForAddresses < ActiveRecord::Migration[6.0]
  def change
    change_column :addresses, :zip_code, :string, null: true
    change_column :addresses, :bn_zip_code, :string, null: true
    change_column :addresses, :phone, :string, null: true
    change_column :addresses, :bn_phone, :string, null: true
  end
end
