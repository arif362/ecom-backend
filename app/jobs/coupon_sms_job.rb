class CouponSmsJob < ApplicationJob
  queue_as :default

  def perform(coupon, phone)
    I18n.locale = :bn
    message = ''
    if coupon.first_registration?
      discount_msg = coupon.percentage? ? 'first_order_coupon_percentage' : 'first_order_coupon_fixed'
      message = I18n.t(discount_msg,
                       discount_amount: coupon.discount_amount.to_i, coupon_code: coupon.code,
                       max_amount: coupon.max_limit)
    end
    SmsManagement::SendMessage.call(phone: phone, message: message)
  end
end
