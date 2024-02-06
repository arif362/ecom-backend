class TransferBusinessTypeToProductFromVariant < ActiveRecord::Migration[6.0]
  def change
    remove_column :variants, :business_type
    add_column :products, :business_type, :integer, default: 0
  end
end
