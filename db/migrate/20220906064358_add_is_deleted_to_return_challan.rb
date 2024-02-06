class AddIsDeletedToReturnChallan < ActiveRecord::Migration[6.0]
  def change
    add_column :return_challans, :is_deleted, :boolean, default: false
  end
end
