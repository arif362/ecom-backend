class CreateUserModificationRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :user_modification_requests do |t|
      t.bigint :user_id, null: false
      t.integer :request_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.bigint :user_modify_reason_id, null: false
      t.text :reject_reason

      t.timestamps
    end
  end
end
