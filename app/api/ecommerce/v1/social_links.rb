# frozen_string_literal: true

module Ecommerce
  module V1
    class SocialLinks < Ecommerce::Base
      resources :social_links do
        # CREATE INFO
        desc 'ADD SOCIAL MEDIA'
        params do
          requires :name, type: String
          requires :url, type: String
        end
        post do
          social_link = SocialLink.new(params)
          if social_link.save
            social_link
          else
            respond_with_json('Unsuccessful', 500)
          end
        rescue StandardError => ex
          respond_with_json("Can not create due to #{ex.message}", 500)
        end

        # SHOW AN INFO
        desc 'SHOW INFO'
        route_param :id do
          get '/show' do
            social_link = SocialLink.find(params[:id])
          rescue StandardError => ex
            respond_with_json("Can not show due to #{ex.message}", 500)
          end
        end

        # UPDATE INFO
        desc 'UPDATE INFO'
        route_param :id do
          params do
            optional :name, type: String
            optional :url, type: String
          end
          put '/update' do
            social_link = SocialLink.find(params[:id])
            if social_link
              social_link.update(params)
              social_link
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
            if social_link = SocialLink.find(params[:id])
              social_link.destroy
            end
          rescue StandardError => ex
            respond_with_json("Can not delete due to #{ex.message}", 500)
          end
        end
      end
    end
  end
end
