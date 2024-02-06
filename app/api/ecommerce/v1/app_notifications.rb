module Ecommerce
  module V1
    class AppNotifications < Ecommerce::Base
      resource :app_notifications do
        desc 'Ecommerce App Notification.'
        get do
          notifications = @current_user.app_notifications.order(id: :desc)
          result = notifications.select(:id, :title, :bn_title, :message, :bn_message, :read, :created_at)
          notifications.where(read: false).update(read: true)
          success_response_with_json('Notifications fetched successfully', HTTP_CODE[:OK], result)
        rescue StandardError => error
          Rails.logger.info "#{__FILE__} \nUnable to fetch notifications due to #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.notification_fetch_failed'), HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
