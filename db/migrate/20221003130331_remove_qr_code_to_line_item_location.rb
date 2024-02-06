class RemoveQrCodeToLineItemLocation < ActiveRecord::Migration[6.0]
  def change
    remove_column :line_item_locations, :qr_code, :string
  end
end
