# frozen_string_literal: true

module ShopothWarehouse
  module V1
    class Sessions < ShopothWarehouse::Base
      resource :sessions do
        params do
          requires :email, type: String
          requires :password, type: String
        end

        desc 'login'
        post do
          staff = Staff.find_by_email(params[:email])
          if staff.password == params[:password]
            'success'
          else
            'faild'
          end
        end
      end
    end
  end
end
