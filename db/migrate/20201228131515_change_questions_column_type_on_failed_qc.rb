class ChangeQuestionsColumnTypeOnFailedQc < ActiveRecord::Migration[6.0]
  def change
    remove_column :failed_qcs, :questions, :string
    add_column :failed_qcs, :failed_reasons, :jsonb, default: {}
  end
end
