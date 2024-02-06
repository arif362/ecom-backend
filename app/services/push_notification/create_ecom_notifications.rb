module PushNotification
  class CreateEcomNotifications
    include Interactor

    delegate :app_user,
             :notification,
             :details,
             :bn_details,
             :attributes,
             to: :context

    def call
      context.notification = Notification.new notification_attributes
      if notification.save
        PushNotification::Android.call fcm_attributes
      else
        context.fail!(error: notification.errors.full_detailss.to_sentence)
      end
    end

    private

    def notification_attributes
      {
        details: context.details,
        bn_details: context.bn_details,
        user: context.app_user,
      }
    end

    def fcm_attributes
      Rails.logger.info "Title: #{context.attributes[:title]} \nMessage: #{context.attributes[:details]} \n"
      {
        fcm_token: context.app_user&.app_config&.fcm_token,
        title: context.attributes[:title],
        message: context.attributes[:details],
      }
    end
  end
end
