class AddColumnsToFailedQcs < ActiveRecord::Migration[6.0]
  def change
    add_column :failed_qcs, :is_settled, :boolean, default: false
  end
end
