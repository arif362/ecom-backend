module ShopothWarehouse
  module V1
    class Articles < ShopothWarehouse::Base
      resource :articles do
        desc 'get article list of a topic'
        get do
          # TODO: Need to Optimize Query
          articles = paginate(Kaminari.paginate_array(Article.order(created_at: :desc)))
          success_response_with_json('Successfully Fetch', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::Articles.represent(articles))
        rescue StandardError => error
          Rails.logger.info "admin: article fetch error #{error.message}"
          error!(failure_response_with_json("Failed to fetch #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                 HTTP_CODE[:OK])
        end

        route_param :id do
          desc 'details of an article'
          get do
            article = Article.find(params[:id])
            success_response_with_json('Successfully Fetch', HTTP_CODE[:OK],
                                       ShopothWarehouse::V1::Entities::Articles.represent(article))
          rescue StandardError => error
            Rails.logger.info "admin: article fetch error #{error.message}"
            error!(failure_response_with_json("Failed to fetch #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                   HTTP_CODE[:OK])
          end

          desc 'edit an article'
          params do
            requires :title, type: String
            requires :bn_title, type: String
            requires :slug, type: String
            requires :body, type: String
            optional :bn_body, type: String
            requires :public_visibility, type: Boolean
            requires :help_topic_id, type: Integer
            optional :footer_visibility, type: Boolean
            optional :position, type: Integer
            optional :meta_datum_attributes, type: Hash do
              optional :meta_keyword, type: Array
              optional :bn_meta_keyword, type: Array
              optional :meta_title, type: String
              optional :bn_meta_title, type: String
              optional :meta_description, type: String
              optional :bn_meta_description, type: String
            end
          end
          put do
            article = Article.find(params[:id])

            unless article
              error!(failure_response_with_json('Article not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end

            if params[:meta_datum_attributes].present?
              meta_datum_id = article.meta_datum&.id
              params[:meta_datum_attributes] = params[:meta_datum_attributes].merge(id: meta_datum_id)
            end

            article.update!(params)
            success_response_with_json('Successfully edited', HTTP_CODE[:OK], {})

          rescue StandardError => error
            Rails.logger.info "admin: article edit error #{error.message}"
            error!(failure_response_with_json("Failed to edit #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                   HTTP_CODE[:OK])
          end
        end

        desc 'create article'
        params do
          requires :help_topic_id, type: Integer
          requires :title, type: String
          requires :bn_title, type: String
          requires :slug, type: String
          requires :body, type: String
          optional :bn_body, type: String
          optional :public_visibility, type: Boolean
          optional :footer_visibility, type: Boolean
          optional :position, type: Integer
          optional :meta_datum_attributes, type: Hash do
            optional :meta_keyword, type: Array
            optional :bn_meta_keyword, type: Array
            optional :meta_title, type: String
            optional :bn_meta_title, type: String
            optional :meta_description, type: String
            optional :bn_meta_description, type: String
          end
        end
        post do
          topic = HelpTopic.find(params[:help_topic_id])
          declared_params = declared(params, include_missing: false)
          declared_params.merge!(created_by_id: @current_staff.id)
          topic.articles.create!(declared_params)
          success_response_with_json('Successfully created', HTTP_CODE[:CREATED], {})

        rescue StandardError => error
          Rails.logger.info "admin: article create error #{error.message}"
          error!(failure_response_with_json("Failed to create #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                 HTTP_CODE[:OK])
        end

        desc 'delete a help topic'
        route_param :id do
          delete do
            article = Article.find(params[:id])
            article.destroy!
            success_response_with_json('Successfully deleted', HTTP_CODE[:OK], {})
          rescue StandardError => error
            Rails.logger.info "admin: help topic delete error #{error.message}"
            error!(failure_response_with_json("Failed to delete #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                   HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end
