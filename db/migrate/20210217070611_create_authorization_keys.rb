class CreateAuthorizationKeys < ActiveRecord::Migration[6.0]
  def change
    create_table :authorization_keys do |t|
      t.text :token
      t.string :otp
      t.datetime :expiry
      t.integer :user_id

      t.timestamps
    end
  end
end