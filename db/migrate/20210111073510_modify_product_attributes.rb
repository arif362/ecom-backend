class ModifyProductAttributes < ActiveRecord::Migration[6.0]
  def change
    change_column_null :products, :temperature_requirement, null: true
    change_column_null :products, :bn_temperature_requirement, null: true
  end
end
