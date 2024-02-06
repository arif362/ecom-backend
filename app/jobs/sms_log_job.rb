class SmsLogJob < ApplicationJob
  queue_as :default

  def perform(sms_type, phone, content, gateway_response)
    SmsLog.create!(sms_type: sms_type, phone: phone, content: content, gateway_response: gateway_response)
  end
end
