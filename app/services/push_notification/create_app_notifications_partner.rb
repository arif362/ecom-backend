module PushNotification
  class CreateAppNotificationsPartner
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
        PushNotification::Android.call fcm_attributes
      else
        context.fail!(error: notification.errors.full_messages.to_sentence)
      end
    end

    private

    def notification_attributes
      Rails.logger.info "Title: #{context.attributes[:title]} \nBn_title: #{context.attributes[:bn_title]} \nMessage: #{context.attributes[:message]} \nBn_message: #{context.attributes[:bn_message]} \n"
      {
        title: context.title,
        bn_title: context.bn_title,
        message: context.message,
        bn_message: context.bn_message,
        notifiable: context.app_user,
      }
    end

    def fcm_attributes
      Rails.logger.info "Title: #{context.attributes[:title]} \nMessage: #{context.attributes[:message]} \n"
      {
        fcm_token: context.app_user&.app_config&.fcm_token,
        title: context.attributes[:title],
        message: context.attributes[:message],
      }
    end
  end
end
