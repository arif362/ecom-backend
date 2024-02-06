class AddIsActiveToStaffs < ActiveRecord::Migration[6.0]
  def change
    add_column :staffs, :is_active, :boolean, default: true
  end
end
