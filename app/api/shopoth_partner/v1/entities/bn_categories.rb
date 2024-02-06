module ShopothPartner
  module V1
    module Entities
      class BnCategories < Grape::Entity
        expose :id
        expose :title
        expose :image
        expose :sub_categories

        def title
          object.bn_title
        end

        def sub_categories
          if options[:is_b2b]
            ShopothPartner::V1::Entities::BnCategories.represent(object.sub_categories.b2b_categories.order(:position), is_b2b: true)
          else
            ShopothPartner::V1::Entities::BnCategories.represent(object.sub_categories.b2b_categories.order(:position))
          end
        end

        def image
          object.get_app_img("small")
        end
      end
    end
  end
end
