# frozen_string_literal: true

module Ecommerce
  module V1
    class HelpTopics < Ecommerce::Base
      resource :help_topics do
        desc 'Fetch topics.'
        params do
          use :pagination, per_page: 50
        end
        route_setting :authentication, optional: true
        get do
          # TODO: Need to Optimize Query
          help_topics = paginate(Kaminari.paginate_array(HelpTopic.published.order(id: :desc)))
          success_response_with_json('Successfully Fetch', HTTP_CODE[:OK],
                                     Ecommerce::V1::Entities::HelpTopics.represent(help_topics))
        rescue StandardError => error
          Rails.logger.info "help topics fetch error #{error.message}"
          error!(failure_response_with_json('Failed to fetch', HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                 HTTP_CODE[:OK])
        end

        route_setting :authentication, optional: true
        route_param :slug do
          desc 'article fetch'
          params do
            use :pagination, per_page: 50
          end
          get do
            topic = HelpTopic.find_by(slug: params[:slug])
            articles = topic.articles.published.order(id: :desc)
            success_response_with_json('Successfully Fetch', HTTP_CODE[:OK],
                                       Ecommerce::V1::Entities::Articles.represent(articles))
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



