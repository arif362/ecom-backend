class SmsLog < ApplicationRecord
  enum sms_type: { otp: 0, registration: 1, customer_order: 2, return_voucher: 3 }

  def self.exit_sms_limit?(phone)
    where('created_at >= ? AND phone = ?', 1.hours.ago, phone).length >= 3
  end
end
