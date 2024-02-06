# frozen_string_literal: true

module Ecommerce
  module V1
    class UserPreferences < Ecommerce::Base
      resource :user_preferences do
        # TODO: GET ALL USER PREFERENCES FOR ADMIN

        # GET THE CURRENT USER PREFERENCE
        desc 'RETURN CURRENT USER PREFERENCES'
        get do
          user_pref = @current_user.user_preference
          if user_pref
            present user_pref,
                    with: Ecommerce::V1::Entities::UserPreferences
          else
            []
          end
        rescue StandardError => e
          respond_with_json(e, 500)
        end

        # CREATE REVIEW FOR A PRODUCT BY A USER
        desc 'CREATE/UPDATE USER PREFERENCE FOR CURRENT USER'
        params do
          optional :default_delivery_method, type: String
          optional :mail_notification, type: String
          optional :smart_notification, type: String
          optional :cellular_notification, type: String
          optional :subscription, type: String
        end
        post do
          user_pref = @current_user.user_preference
          if user_pref
            if user_pref.update(params)
              respond_with_json('Succesfully Updated', 200)
            else
              respond_with_json('Unsuccesful Operation', 500)
            end
          else
            user_pref = UserPreference.new(params)
            user_pref.user_id = @current_user.id
            if user_pref.save
              respond_with_json('Succesfully Created', 201)
            else
              respond_with_json('Unsuccesful Operation', 500)
            end
          end
        rescue StandardError => e
          respond_with_json(e, 500)
        end
      end
    end
  end
end
