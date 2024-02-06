module ShopothRider
  module V1
    class AppNotifications < ShopothRider::Base

      resource :app_notifications do
        desc 'Rider App Notification'
        get do
          notifications = @current_rider.app_notifications.order(id: :desc)
          result = notifications.select(:id, :title, :message, :read, :created_at)
          notifications.where(read: false).update(read: true)
          status :ok
          result
        rescue => ex
          error!("Unable to get notifications due to #{ex.message}")
        end


        # desc 'Update app config'
        # put 'config' do
        #   params do
        #     requires :fcm_token, type: String
        #   end
        #   @current_rider.create_app_config() if @current_rider.app_config.nil?
        #   unread_notifications = @current_rider.app_notifications.where(read: false).count
        #   @current_rider.app_config.update!(fcm_token: params[:fcm_token])
        #   {
        #     unread_notifications: unread_notifications,
        #     force_update: @current_rider.app_config.force_update,
        #     latest_app_version: @current_rider.app_config.latest_app_version,
        #   }
        # rescue => ex
        #   error!("Unable to update fcm token due to #{ex.message}")
        # end
      end
    end
  end
end
