# frozen_string_literal: true

module Ecommerce
  module V1
    class StoreInfos < Ecommerce::Base
      resources :store_infos do
        # CREATE INFO
        desc 'CREATE INFO'
        params do
          requires :official_email, type: String
          requires :contact_address, type: String
          requires :contact_number, type: String
          optional :footer_bottom, type: String
        end
        post do
          info = StoreInfo.new(params)
          if info.save
            info
          else
            respond_with_json('Unsuccessful', 500)
          end
        rescue StandardError => ex
          respond_with_json("Can not create due to #{ex.message}",500)
        end

        # SHOW AN INFO
        desc 'SHOW INFO'
        route_param :id do
          get '/show' do
            info = StoreInfo.find(params[:id])
          rescue StandardError => ex
            respond_with_json("Can not show due to #{ex.message}", 500)
          end
        end

        # UPDATE INFO
        desc 'UPDATE INFO'
        route_param :id do
          params do
            optional :official_email, type: String
            optional :contact_address, type: String
            optional :contact_number, type: String
            optional :footer_bottom, type: String
          end
          put '/update' do
            info = StoreInfo.find(params[:id])
            if info
              info.update(params)
              info
            else
              respond_with_json('Unsuccessful', 500)
            end
          rescue StandardError => ex
            respond_with_json("Can not update due to #{ex.message}", 500)
          end
        end

        # DELETE AN INFO
        desc 'DELETE AN INFO'
        route_param :id do
          delete do
            if info = StoreInfo.find(params[:id])
              info.destroy
            end
          rescue StandardError => ex
            respond_with_json("Can not delete due to #{ex.message}", 500)
          end
        end
      end
    end
  end
end
