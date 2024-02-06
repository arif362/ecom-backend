class PaymentMailer < ApplicationMailer
  def successful(order)
    customer = order.customer
    @order = order
    @name = customer.name

    mail(to: customer.email, subject: t('layouts.mailer.payment.subject'))
  end

  def failure(order)
    customer = order.customer
    @order = order
    @name = customer.name

    mail(to: customer.email, subject: t('layouts.mailer.payment.subject_failed'))
  end
end
