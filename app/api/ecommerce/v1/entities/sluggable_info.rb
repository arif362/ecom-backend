module Ecommerce
  module V1
    module Entities
      class SluggableInfo < Grape::Entity
        expose :slug
        expose :page
        expose :meta_info

        def page
          options[:friendly_id_slug].sluggable_type
        end

        def meta_info
          {}
        end
      end
    end
  end
end
