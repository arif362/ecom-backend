class AddAddressLineColToSupplier < ActiveRecord::Migration[6.0]
  def change
    add_column :suppliers, :address_line, :text
  end
end
