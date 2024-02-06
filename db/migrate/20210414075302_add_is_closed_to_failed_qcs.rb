class AddIsClosedToFailedQcs < ActiveRecord::Migration[6.0]
  def change
    add_column :failed_qcs, :is_closed, :boolean, default: false
  end
end
