class ChangeDangerousGoodsTypeToStringOnProducts < ActiveRecord::Migration[6.0]
  def change
    change_column :products, :dangerous_goods, :string
  end
end
