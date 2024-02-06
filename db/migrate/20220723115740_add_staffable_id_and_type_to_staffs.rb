class AddStaffableIdAndTypeToStaffs < ActiveRecord::Migration[6.0]
  def change
    add_column :staffs, :staffable_id, :integer
    add_column :staffs, :staffable_type, :string
  end
end
