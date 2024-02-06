class AddReasonTypeToUserModifyReasons < ActiveRecord::Migration[6.0]
  def change
    add_column :user_modify_reasons, :reason_type, :integer, default: 0
  end
end
