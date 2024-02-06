module ShopothWarehouse
  module V1
    module Entities
      class Articles < Grape::Entity
        expose :id
        expose :title
        expose :slug
        expose :footer_visibility
        expose :position
        expose :bn_title
        expose :body
        expose :bn_body
        expose :public_visibility
        expose :help_topic_id
        expose :help_topic_name
        expose :meta_info
        expose :is_deletable
        expose :created_by

        def help_topic_name
          object.help_topic&.title
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
