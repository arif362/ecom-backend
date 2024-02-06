# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class Permissions < ShopothWarehouse::Base
      resource :permissions do

        desc 'Return list of permissions'
        get do
          Permission.all
        end

        desc 'create a new permission'
        params do
          requires :resource_name, type: String
          requires :staff_id, type: Integer
        end
        post do
          permission = Permission.new(params)
          permission if permission.save!
        rescue StandardError
          error! respond_with_json('Unable to create Permission.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Update a specific permission'
        route_param :id do
          put do
            permission = Permission.find(params[:id])
            permission if permission.update!(params)
          rescue StandardError
            error! respond_with_json('Unable to update Permission.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Delete a specific permission'
        route_param :id do
          delete do
            permission = Permission.find(params[:id])
            'Successfully deleted.' if permission.destroy!
          rescue StandardError
            error! respond_with_json('Unable to update Permission.', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end
      end
    end
  end
end
