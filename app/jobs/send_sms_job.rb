class SendSmsJob < ApplicationJob
  queue_as :default

  def perform(order)
    if order.cash_on_delivery?
      delivery_date = order.express_delivery? ? order.created_at + 3.hours : order.created_at + 72.hours
      delivery_date = delivery_date.to_date.strftime('%d-%m-%Y')
      previous_local = I18n.locale
      I18n.locale = :bn
      message = if order.pick_up_point?
                  I18n.t('order_place_pick_up', customer_name: order.name, order_id: order.backend_id,
                                                delivery_date: delivery_date, total_price: order.total_price.to_i,
                                                outlet_name: order&.partner&.name)
                else
                  I18n.t('order_place_delivery', customer_name: order.name, order_id: order.backend_id,
                                                 total_price: order.total_price.to_i, delivery_date: delivery_date)
                end

      I18n.locale = previous_local
      SmsManagement::SendMessage.call(phone: order.phone, message: message)
    end

    if order.order_type == 'organic' && order.partner.present?
      app_notification = AppNotification.order_delivery_notification(order)
      PushNotification::CreateAppNotifications.call(
        app_user: order.partner,
        title: app_notification[:title],
        bn_title: app_notification[:bn_title],
        message: app_notification[:message],
        bn_message: app_notification[:bn_message],
      )
    end
  end
end
