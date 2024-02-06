module SmsManagement
  class SendOtp
    include Interactor::Organizer

    organize(
      SmsManagement::SendOtp::DeliverMessage,
      SmsManagement::SendOtp::GenerateEncryptedHash,
    )
  end
end
