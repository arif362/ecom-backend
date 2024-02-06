class NotificationMailer < ApplicationMailer
  def notify(email, request_type, status, name)
    @name = name
    @status = status
    @request_type = request_type
    @message = ''
    case request_type
    when 'deactivated'
      @text_pending = 'deactivation'
      @text_approved = 'deactivated'
    when 'deleted'
      @text_pending = 'deletion'
      @text_approved = 'deleted'
    else
      @text_pending = ''
      @text_approved = ''
    end
    mail(to: email, subject: 'Account Deactivation/Deletion request')
  end
end
