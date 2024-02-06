module ShopothWarehouse
  module V1
    class DhManagerStaffs < ShopothWarehouse::Base
      resources :dh_manager_staffs do
        params do
          requires :first_name, type: String
          requires :last_name, type: String
          requires :email, type: String
          requires :password, type: String
          requires :ware_house_id, type: Integer
          requires :staff_role_id, type: Integer
        end

        desc 'Create a staff by distribution house manager'
        post do
          staff = Staff.new(params)
          staff if staff.save!
        rescue StandardError => e
          error! respond_with_json("Unable to create Staff due to #{e.message}",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end