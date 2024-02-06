# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class StaffRoles < ShopothWarehouse::Base
      resource :staff_roles do
        params do
          requires :name
        end

        desc 'create a new Staff Role'
        post do
          staff_role = StaffRole.new(params)
          staff_role if staff_role.save!
        rescue StandardError => e
          error! respond_with_json("Unable to create Staff_Role due to #{e.message}.",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Update a specific Staff Role'
        route_param :id do
          put do
            staff_role = StaffRole.find(params[:id])
            staff_role if staff_role.update!(params)
          rescue StandardError => e
            error! respond_with_json("Unable to update Staff_Role with id #{params[:id]} due to #{e.message}.",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Delete a specific Staff Role'
        route_param :id do
          delete do
            staff_role = StaffRole.find(params[:id])
            staff_role if staff_role.destroy!
          rescue StandardError => e
            error! respond_with_json("Unable to delete Staff_Role with id #{params[:id]} due to #{e.message}.",
                                     HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end
        end

        desc 'Return list of staff role'
        get do
          StaffRole.all
        end

        desc 'Return a staff role'
        get ':id' do
          staff_role = StaffRole.find(params[:id])
          staff_role if staff_role.present?
        rescue StandardError => e
          error! respond_with_json("Unable to find Staff_Role with id #{params[:id]} due to #{e.message}.",
                                   HTTP_CODE[:NOT_FOUND])
        end
      end
    end
  end
end
