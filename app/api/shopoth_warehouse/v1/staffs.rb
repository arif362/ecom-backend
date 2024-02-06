# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class Staffs < ShopothWarehouse::Base
      resource :staffs do
        params do
          requires :first_name, type: String
          requires :last_name, type: String
          requires :email, type: String
          requires :password, type: String
          requires :password_confirmation, type: String
          requires :staff_role_id, type: Integer
          optional :address_line, type: String
        end

        desc 'Sign up a new Staff'
        post '/signup' do
          staff = Staff.new(params.merge(warehouse: @current_staff.warehouse))

          if staff.save
            respond_with_json(staff, HTTP_CODE[:OK])
          else
            respond_with_json(
              staff.errors.full_messages.to_sentence,
              HTTP_CODE[:UNPROCESSABLE_ENTITY],
            )
          end
        end

        params do
          requires :email, type: String
          requires :password, type: String
        end

        desc 'Log in a existing staff'
        route_setting :authentication, optional: true

        post '/login' do
          staff = Staff.find_by(email: params[:email])
          unless staff
            error!(failure_response_with_json('Staff not found', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:OK])
          end
          unless staff.staffable_type == 'Warehouse' && staff.staffable.active?
            error!(failure_response_with_json('Invalid', HTTP_CODE[:NOT_ACCEPTABLE]), HTTP_CODE[:OK])
          end
          unless staff.fulfilment_center? || staff.central_warehouse?
            error!(failure_response_with_json('Invalid', HTTP_CODE[:NOT_ACCEPTABLE]),
                   HTTP_CODE[:OK])
          end
          if staff.valid_password?(params[:password])
            respond_with_json(
              {
                token: JsonWebToken.single_login_token_encode(staff),
                warehouse_name: staff.warehouse&.name,
                user_name: staff.name,
                warehouse_type: staff.warehouse&.warehouse_type,
                district_id: staff.warehouse&.address&.district_id,
              }, HTTP_CODE[:OK]
            )
          else
            respond_with_json({ error: 'invalid' }, HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Update a specific Staff'
        route_param :id do
          put do
            staff = Staff.find(params[:id])
            if staff.present?
              staff.update!(params)
              staff.as_json(include: :permissions)
            end
          rescue StandardError => error
            error! respond_with_json("Unable to update Staff with id #{params[:id]} due to #{error.message}",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Delete a specific Staff'
        route_param :id do
          delete do
            Staff.find(params[:id]).destroy!
            respond_with_json("Successfully deleted staff with id #{params[:id]}", HTTP_CODE[:OK])
          rescue StandardError => error
            error! respond_with_json("Unable to delete Staff with id #{params[:id]} due to #{error.message}",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Return list of staff'
        get do
          Staff.all.order(created_at: :desc).as_json(include: :permissions)
        end

        desc 'Return a staff'
        get ':id' do
          staff = Staff.find(params[:id])
          staff.as_json(include: :permissions) if staff.present?

        rescue StandardError => error
          error! respond_with_json("Unable to find Staff with id #{params[:id]} due to #{error.message}",
                                   HTTP_CODE[:NOT_FOUND])
        end
      end
    end
  end
end
