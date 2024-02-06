class IncludedAdditionalStatusIntoUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_otp_verified, :boolean, null: false, default: false
    add_column :users, :is_deleted, :boolean, null: false, default: false
  end
end
