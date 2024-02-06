class ClosingTimeFailedQcs < ActiveRecord::Migration[6.0]
  def change
    add_column :failed_qcs, :closed_at, :datetime
  end
end
