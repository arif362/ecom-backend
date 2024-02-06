class RemoveIsClosed < ActiveRecord::Migration[6.0]
  def change
    remove_column :failed_qcs, :is_closed, :boolean
  end
end
