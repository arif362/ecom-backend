module ShopothWarehouse
  module V1
    class AppNotifications < ShopothWarehouse::Base

      resource :app_notifications do
        # Get Route App Notification *********
        desc 'Route App Notification'
        route_setting :authentication, type: RouteDevice
        get do
          page = params[page].present? ? params[page] : 1
          notifications = @current_route_device.route.app_notifications.order(id: :desc)
          result = notifications.select(:id, :title, :message, :read, :created_at)
          notifications.where(read: false).update(read: true)
          status :ok
          result
        rescue => ex
          error!("Unable to fetch notifications due to #{ex.message}")
        end

        # desc 'Update app config'
        # route_setting :authentication, type: RouteDevice
        # put 'config' do
        #   params do
        #     requires :fcm_token, type: String
        #   end
        #   @current_route_device.route.create_app_config() if @current_route_device.route.app_config.nil?
        #   unread_notifications = @current_route_device.route.app_notifications.where(read: false).count
        #   @current_route_device.route.app_config.update!(fcm_token: params[:fcm_token])
        #   {
        #     unread_notifications: unread_notifications,
        #     force_update: @current_route_device.route.app_config.force_update,
        #     latest_app_version: @current_route_device.route.app_config.latest_app_version,
        #   }
        # rescue => ex
        #   error!("Unable to update fcm token due to #{ex.message}")
        # end
      end
    end
  end
end
