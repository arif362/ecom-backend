class ChangeWeightColumnOfProducts < ActiveRecord::Migration[6.0]
  def change
    change_column_null :products, :weight, false
  end
end
