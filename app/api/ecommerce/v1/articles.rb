# frozen_string_literal: true

module Ecommerce
  module V1
    class Articles < Ecommerce::Base
      resource :articles do
        desc 'Fetch articles.'
        params do
          use :pagination, per_page: 50
        end
        route_setting :authentication, optional: true
        get '/search' do
          # TODO: Need to Optimize Query
          articles = if params[:title].present?
                       paginate(Kaminari.paginate_array(
                                  Article.search_by_title(params[:title]).order(id: :desc)))
                     else
                       paginate(Kaminari.paginate_array(Article.all.order(id: :desc)))
                     end
          success_response_with_json('Successfully Fetch', HTTP_CODE[:OK],
                                     Ecommerce::V1::Entities::Articles.represent(articles))
        rescue StandardError => error
          Rails.logger.info "articles fetch error #{error.message}"
          error!(failure_response_with_json('Failed to fetch', HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                 HTTP_CODE[:OK])
        end

        route_setting :authentication, optional: true
        route_param :id do
          get do
            article = Article.friendly.find(params[:id])
            success_response_with_json('Successfully Fetch', HTTP_CODE[:OK],
                                       Ecommerce::V1::Entities::Articles.represent(article))
          rescue StandardError => error
            Rails.logger.info "articles fetch error #{error.message}"
            error!(failure_response_with_json('Failed to fetch', HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                   HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end



