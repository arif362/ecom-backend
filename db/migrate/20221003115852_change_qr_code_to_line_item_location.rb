class ChangeQrCodeToLineItemLocation < ActiveRecord::Migration[6.0]
  def up
    change_column :line_item_locations, :qr_code, :string
  end

  def down
    change_column :line_item_locations, :qr_code, :integer
  end
end
