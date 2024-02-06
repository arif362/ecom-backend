module Ecommerce
  module V1
    module Entities
      class StaticPages < Grape::Entity
        expose :id
        expose :page_type
        expose :meta_info

        def page_type
          object.page_type&.titleize
        end

        def meta_info
          Ecommerce::V1::Entities::MetaData.represent(object.meta_datum)
        end
      end
    end
  end
end
