class AddIsDeletedToChallan < ActiveRecord::Migration[6.0]
  def change
    add_column :challans, :is_deleted, :boolean, default: false
  end
end
