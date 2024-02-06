class CustomerAcquisitionSmsJob < ApplicationJob
  queue_as :default

  def perform(phone, message)
    SmsManagement::SendMessage.call(phone: phone, message: message)
  end
end
