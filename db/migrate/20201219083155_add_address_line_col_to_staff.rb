class AddAddressLineColToStaff < ActiveRecord::Migration[6.0]
  def change
    add_column :staffs, :address_line, :string, null: false
  end
end
