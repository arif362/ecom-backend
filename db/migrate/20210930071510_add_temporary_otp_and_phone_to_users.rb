class AddTemporaryOtpAndPhoneToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :temporary_otp, :string
    add_column :users, :temporary_phone, :string
  end
end
