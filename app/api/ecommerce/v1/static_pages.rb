# frozen_string_literal: true

module Ecommerce
  module V1
    class StaticPages < Ecommerce::Base
      resource :static_pages do

        # SHOW A STATIC PAGE WITH META
        desc 'SHOW A STATIC PAGE'
        route_setting :authentication, optional: true
        get '/:page_type' do
          static_page = StaticPage.find_by(page_type: params[:page_type])
          if static_page.present?
            static_page = Ecommerce::V1::Entities::StaticPages.represent(static_page)
            success_response_with_json('Successfully Fetch', HTTP_CODE[:OK], static_page)
          else
            error!(failure_response_with_json('Static Page Not Found.', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
          end

        rescue StandardError => error
          error!(failure_response_with_json(error, HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
        end
      end
    end
  end
end
