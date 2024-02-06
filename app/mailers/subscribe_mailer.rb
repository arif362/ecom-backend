class SubscribeMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.subscribe_mailer.create_subscribe_mail.subject
  #
  def create_subscribe_mail(user_email, token)
    @greeting = 'Thanks for subscribing to shopoth.'
    @root_url = ENV['ROOT_URL']
    @token = token
    mail(
      from: 'debashish.halder@misfit.tech',
      to: user_email,
      subject: @greeting,
    )
  end
end
