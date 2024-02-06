class AddFailedTypeToFailedQcs < ActiveRecord::Migration[6.0]
  def change
    add_column :failed_qcs, :qc_failed_type, :integer, default: 0
  end
end
