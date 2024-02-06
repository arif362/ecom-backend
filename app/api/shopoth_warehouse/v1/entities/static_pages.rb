module ShopothWarehouse
  module V1
    module Entities
      class StaticPages < Grape::Entity
        expose :id
        expose :page_type
        expose :page_type_key
        expose :meta_info

        def page_type
          object.page_type&.titleize
        end

        def page_type_key
          StaticPage.page_types[object.page_type]
        end

        def meta_info
          ShopothWarehouse::V1::Entities::MetaData.represent(object.meta_datum)
        end
      end
    end
  end
end
