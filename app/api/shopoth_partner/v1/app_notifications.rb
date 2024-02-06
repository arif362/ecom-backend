module ShopothPartner
  module V1
    class AppNotifications < ShopothPartner::Base

      resource :app_notifications do
        desc 'Partner App Notification.'
        get do
          notifications = @current_partner.app_notifications.order(id: :desc)
          notifications.where(read: false).update(read: true)
          status :ok

          if @locale == :bn
            present notifications, with: ShopothPartner::V1::Entities::BnResult
          else
            present notifications, with: ShopothPartner::V1::Entities::Result
          end
        rescue StandardError => error
          Rails.logger.info "#{__FILE__} \nUnable to fetch notifications due to #{error.message}"
          error!(respond_with_json(I18n.t('Partner.errors.messages.notification_fetch_failed'),
                                   HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
        end

        # desc 'Update app config'
        # put 'config' do
        #   params do
        #     requires :fcm_token, type: String
        #   end
        #   @current_partner.create_app_config() if @current_partner.app_config.nil?
        #   unread_notifications = @current_partner.app_notifications.where(read: false).count
        #   @current_partner.app_config.update!(fcm_token: params[:fcm_token])
        #   {
        #     unread_notifications: unread_notifications,
        #     force_update: @current_partner.app_config.force_update,
        #     latest_app_version: @current_partner.app_config.latest_app_version,
        #   }
        # rescue => ex
        #   error!("Unable to update fcm token due to #{ex.message}")
        # end
      end
    end
  end
end
