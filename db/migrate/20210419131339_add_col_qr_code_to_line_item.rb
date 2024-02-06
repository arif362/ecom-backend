class AddColQrCodeToLineItem < ActiveRecord::Migration[6.0]
  def change
    add_column :line_items, :qr_code, :string, default: ''
  end
end
