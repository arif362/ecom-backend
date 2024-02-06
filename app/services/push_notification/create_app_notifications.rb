module PushNotification
  class CreateAppNotifications
    include Interactor

    delegate :app_user,
             :notification,
             :title,
             :bn_title,
             :message,
             :bn_message,
             :attributes,
             to: :context

    def call
      context.notification = AppNotification.new notification_attributes
      if notification.save
        Rails.logger.info 'Successfully created Notification.'
        PushNotification::Android.call fcm_attributes
        Rails.logger.info 'Successfully pushed Notification.'
      else
        context.fail!(error: notification.errors.full_messages.to_sentence)
      end
    end

    private

    def notification_attributes
      {
        title: context.title,
        bn_title: context.bn_title,
        message: context.message,
        bn_message: context.bn_message,
        notifiable: context.app_user,
      }
    end

    def fcm_attributes
      {
        fcm_token: context.app_user&.app_config&.fcm_token,
        title: context.attributes.present? ? context.attributes[:title] : context.bn_title,
        message: context.attributes.present? ? context.attributes[:message] : context.bn_message,
      }
    end
  end
end
