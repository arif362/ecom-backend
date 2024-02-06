module Ecommerce
  module V1
    module Entities
      class Articles < Grape::Entity
        expose :id
        expose :title
        expose :slug
        expose :bn_title
        expose :body
        expose :bn_body
        expose :position
        expose :bn_body
        expose :help_topic_id
        expose :help_topic_name
        expose :help_topic_slug

        def help_topic_name
          object.help_topic.title
        end

        def help_topic_slug
          object.help_topic.slug
        end
      end
    end
  end
end
