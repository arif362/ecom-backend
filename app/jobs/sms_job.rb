class SmsJob < ApplicationJob
  queue_as :default

  def perform(message, phone)
    I18n.locale = :bn
    SmsManagement::SendMessage.call(phone: phone, message: message)
  end
end
