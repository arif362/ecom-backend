class AddWarehouseReferenceToDistricts < ActiveRecord::Migration[6.0]
  def change
    add_reference :districts, :warehouse, foreign_key: true
  end
end
