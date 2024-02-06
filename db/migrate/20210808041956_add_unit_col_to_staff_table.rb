class AddUnitColToStaffTable < ActiveRecord::Migration[6.0]
  def change
    add_column :staffs, :unit, :integer, default: 0
  end
end
