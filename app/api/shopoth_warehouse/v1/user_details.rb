module ShopothWarehouse
  module V1
    class UserDetails < ShopothWarehouse::Base
      namespace :users do
        desc 'Get user details by phone'
        params do
          requires :phone, type: String
        end
        get '/phone' do
          user_details = User.find_user_by_phone(params[:phone])
          if user_details
            present user_details, with: ShopothWarehouse::V1::Entities::UserFindPhones
          else
            'No match found'
          end
        rescue => error
          error!("Unable to return details due to #{error.message}")
        end
      end
    end
  end
end
