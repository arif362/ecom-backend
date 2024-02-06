class AddPhoneNumbersToCoupon < ActiveRecord::Migration[6.0]
  def change
    add_column :coupons, :phone_numbers, :text
  end
end
