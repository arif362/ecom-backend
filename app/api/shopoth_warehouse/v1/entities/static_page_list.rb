module ShopothWarehouse
  module V1
    module Entities
      class StaticPageList < Grape::Entity
        expose :id
        expose :page_type
        expose :meta_title

        def page_type
          object.page_type&.titleize
        end

        def meta_title
          object.meta_datum&.meta_title
        end
      end
    end
  end
end
