class ChangeNullableToFailable < ActiveRecord::Migration[6.0]
  def change
    change_column_null :failed_qcs, :quantity, true
  end
end
