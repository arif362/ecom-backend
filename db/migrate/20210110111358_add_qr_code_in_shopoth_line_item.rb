class AddQrCodeInShopothLineItem < ActiveRecord::Migration[6.0]
  def change
    add_column :shopoth_line_items, :qr_codes, :string, array: true, default: [], index: true
  end
end
