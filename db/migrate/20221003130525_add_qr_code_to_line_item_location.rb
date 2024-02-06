class AddQrCodeToLineItemLocation < ActiveRecord::Migration[6.0]
  def change
    add_column :line_item_locations, :qr_codes, :string, array: true, default: []
  end
end

