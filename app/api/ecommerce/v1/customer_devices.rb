module Ecommerce
  module V1
    class CustomerDevices < Ecommerce::Base
      resource :customer_devices do
        desc 'create Customer device'
        params do
          requires :customer_device, type: Hash do
            requires :device_id, type: String
            requires :device_model, type: String
            requires :device_os_type, type: String
            requires :device_os_version, type: String
            optional :email, type: String
            optional :phone, type: String
            optional :app_version, type: String
            optional :app_language, type: String
            requires :fcm_id, type: String
            optional :ip, type: String
            optional :brand, type: String
            optional :imei, type: String
          end
        end

        route_setting :authentication, optional: true

        post do
          customer_device = CustomerDevice.find_by(device_id: params[:customer_device][:device_id])
          if customer_device
            customer_device.update(params[:customer_device])
            error!(success_response_with_json('CustomerDevice id already exist', HTTP_CODE[:OK], {customer_device_id: customer_device.id}), HTTP_CODE[:OK])
          end
          customer_device = CustomerDevice.create!(params[:customer_device])
          success_response_with_json('Successfully created', HTTP_CODE[:CREATED], {customer_device_id: customer_device.id})

        rescue StandardError => error
          Rails.logger.info "shop: customer device create error #{error.message}"
          error!(failure_response_with_json("Failed to create due to #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                 HTTP_CODE[:OK])
        end

        route_param :id do
          desc 'Update device app language'
          params do
            requires :app_language, type: String
          end
          route_setting :authentication, optional: true

          put :update_language do
            customer_device = CustomerDevice.find_by(id: params[:id])
            unless customer_device.present?
              error!(failure_response_with_json("CustomerDevice not found", HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end

            customer_device.update!(app_language: params[:app_language])
            success_response_with_json('Successfully updated', HTTP_CODE[:OK])
          rescue => error
            error!(failure_response_with_json("Failed to update device due to #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          desc 'Update device user id'

          put :assign_user do
            customer_device = CustomerDevice.find_by(id: params[:id])
            unless customer_device.present?
              error!(failure_response_with_json("CustomerDevice not found", HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end

            unless @current_user
              error!(failure_response_with_json("User not found", HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:NOT_FOUND])
            end

            CustomerDeviceUser.find_or_create_by(customer_device_id: customer_device.id, user_id: @current_user.id)
            success_response_with_json('Successfully Assign', HTTP_CODE[:OK])
          rescue => error
            error!(failure_response_with_json("Failed to update device due to #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
