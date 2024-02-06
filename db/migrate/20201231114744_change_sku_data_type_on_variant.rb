class ChangeSkuDataTypeOnVariant < ActiveRecord::Migration[6.0]
  def change
    change_column :variants, :sku, :string
  end
end
