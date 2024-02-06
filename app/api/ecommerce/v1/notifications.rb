module Ecommerce
  module V1
    class Notifications < Ecommerce::Base
      resources :notifications do
        desc 'Get all notifications of the logged in user.'
        params do
          optional :type, type: String
          use :pagination, per_page: 50
        end
        get do
          notifications = case params[:type]
                          when 'promotion'
                            # TODO: Need to assign all active user when promotion is created
                            @current_user.notifications.where(user_notifiable_type: 'Promotion').update_all(read: true)
                            @current_user.notifications.where(user_notifiable_type: 'Promotion').order('id DESC')
                          when 'customer_order'
                            @current_user.notifications.where(user_notifiable_type: 'CustomerOrder').update_all(read: true)
                            @current_user.notifications.where(user_notifiable_type: 'CustomerOrder').order('id DESC')
                          else
                            @current_user.notifications.update_all(read: true)
                            @current_user.notifications.order('id DESC')
                          end
          # TODO: Need to Optimize Query
          response = Ecommerce::V1::Entities::Notification.represent(
            paginate(Kaminari.paginate_array(notifications)),
          )
          success_response_with_json(I18n.t('Ecom.success.messages.user_notifications_fetch_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to fetch notifications due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.user_notifications_fetch_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Unread notifications count.'
        get '/unread_count' do
          response = { count: @current_user.notifications.where(read: false).count }
          success_response_with_json(I18n.t('Ecom.success.messages.notification_count_successful'),
                                     HTTP_CODE[:OK], response)
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to count notifications due to: #{error.message}"
          error!(failure_response_with_json(I18n.t('Ecom.errors.messages.notification_count_failed'),
                                            HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:OK])
        end

        desc 'Create a notification'
        params do
          optional :details, type: String
        end

        post do
          declared_params = declared(params)

          notification = Notification.new(
            user: @current_user,
            details: declared_params[:details],
          )

          if notification.save
            present notification, with: Ecommerce::V1::Entities::Notification
          else
            respond_with_json(
              notification.errors.full_messages.to_sentence,
              HTTP_CODE[:UNPROCESSABLE_ENTITY],
            )
          end
        end

        route_param :id do
          helpers do
            def notification
              @notification ||= Notification.find(params[:id])
            end
          end

          desc 'Update a notification'
          params do
            optional :details, type: String
            optional :read, type: Boolean
          end

          put do
            declared_params = declared(params, include_missing: false)

            if notification.update(declared_params)
              present notification, with: Ecommerce::V1::Entities::Notification

            else
              respond_with_json(
                notification.errors.full_messages.to_sentence,
                HTTP_CODE[:UNPROCESSABLE_ENTITY],
              )
            end
          end
        end

        desc 'Mark all notifications as read'
        post '/mark_all_read' do
          notifications = @current_user.notifications
          notifications.update_all read: true
          present notification, with: Ecommerce::V1::Entities::Notification
        end
      end
    end
  end
end
