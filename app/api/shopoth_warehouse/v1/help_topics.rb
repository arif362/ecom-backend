module ShopothWarehouse
  module V1
    class HelpTopics < ShopothWarehouse::Base
      resource :help_topics do
        desc 'Fetch all help topics'
        params do
          use :pagination, per_page: 50
          optional :skip_pagination, type: Boolean
        end
        get do
          # TODO: Need to Optimize Query
          topics = if params[:skip_pagination]
                     HelpTopic.order(created_at: :desc)
                   else
                     paginate(Kaminari.paginate_array(HelpTopic.order(created_at: :desc)))
                   end
          success_response_with_json('Successfully Fetch', HTTP_CODE[:OK],
                                     ShopothWarehouse::V1::Entities::HelpTopics.represent(topics))
        rescue StandardError => ex
          Rails.logger.info "admin: help topics fetch error #{ex.message}"
          error!(failure_response_with_json("help topics fetch error #{ex.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                 HTTP_CODE[:OK])
        end

        route_param :id do
          desc 'individual help topic'
          get do
            topic = HelpTopic.find(params[:id])
            success_response_with_json('Successfully Fetch', HTTP_CODE[:OK],
                                       ShopothWarehouse::V1::Entities::HelpTopics.represent(topic))
          rescue StandardError => ex
            Rails.logger.info "admin: help topic fetch error #{ex.message}"
            error!(failure_response_with_json("Failed to fetch #{ex.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                   HTTP_CODE[:OK])
          end

          desc 'edit a help topic'
          params do
            optional :title, type: String
            optional :bn_title, type: String
            optional :public_visibility, type: Boolean
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
            topic = HelpTopic.find(params[:id])

            unless topic
              error!(failure_response_with_json('Help Topic not found', HTTP_CODE[:NOT_FOUND]), HTTP_CODE[:OK])
            end

            if params[:meta_datum_attributes].present?
              meta_datum_id = topic.meta_datum&.id
              params[:meta_datum_attributes] = params[:meta_datum_attributes].merge(id: meta_datum_id)
            end

            topic.update!(params)
            success_response_with_json('Successfully edited', HTTP_CODE[:OK], {})
          rescue StandardError => error
            Rails.logger.info "admin: help topic edit error #{error.message}"
            error!(failure_response_with_json("Failed to edit #{error.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                   HTTP_CODE[:OK])
          end
        end

        desc 'create help topic'
        params do
          requires :title, type: String
          requires :bn_title, type: String
          requires :slug, type: String
          optional :public_visibility, type: Boolean
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
          HelpTopic.create!(declared(params, include_missing: false))
          success_response_with_json('Successfully created', HTTP_CODE[:OK], {})
        rescue StandardError => ex
          Rails.logger.info "admin: help topic create error #{ex.message}"
          error!(failure_response_with_json("Failed to create #{ex.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                 HTTP_CODE[:OK])
        end

        desc 'delete a help topic'
        route_param :id do
          delete do
            topic = HelpTopic.find(params[:id])
            topic.destroy!
            success_response_with_json('Successfully deleted', HTTP_CODE[:OK], {})
          rescue StandardError => ex
            Rails.logger.info "admin: help topic delete error #{ex.message}"
            error!(failure_response_with_json("Failed to delete #{ex.message}", HTTP_CODE[:UNPROCESSABLE_ENTITY], {}),
                   HTTP_CODE[:OK])
          end
        end
      end
    end
  end
end
