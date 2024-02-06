module Ecommerce
  module V1
    module Entities
      class MetaData < Grape::Entity
        expose :meta_title
        expose :bn_meta_title
        expose :meta_description
        expose :bn_meta_description
        expose :meta_keyword
        expose :bn_meta_keyword
      end
    end
  end
end
