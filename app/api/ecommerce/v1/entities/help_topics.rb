module Ecommerce
  module V1
    module Entities
      class HelpTopics < Grape::Entity
        expose :id
        expose :title
        expose :slug
        expose :bn_title
        expose :article_count

        def article_count
          object.articles.count
        end
      end
    end
  end
end
