class RenameRejectReasonToReasonInUserModificationRequest < ActiveRecord::Migration[6.0]
  def change
    rename_column :user_modification_requests, :reject_reason, :reason
  end
end
