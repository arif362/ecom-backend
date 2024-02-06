module ShopothWarehouse
  module V1
    module Entities
      class HelpTopics < Grape::Entity
        expose :id
        expose :title
        expose :bn_title
        expose :slug
        expose :public_visibility
        expose :article_count
        expose :meta_info
        expose :is_deletable
        expose :created_by

        def article_count
          object.articles.count
        end

        def meta_info
          ShopothWarehouse::V1::Entities::MetaData.represent(object.meta_datum)
        end

        def created_by
          {
            id: object.created_by_id,
            name: Staff.unscoped.find_by(id: object.created_by_id)&.name,
          }
        end
      end
    end
  end
end
