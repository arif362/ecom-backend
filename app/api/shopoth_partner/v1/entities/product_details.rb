module ShopothPartner
  module V1
    module Entities
      class ProductDetails < Grape::Entity
        include ShopothPartner::V1::Helpers::ImageHelper

        expose :id
        expose :title do |model, options|
          options[:language] == 'bn' ? model.bn_title : model.title
        end
        expose :hero_image

        def hero_image
          begin
            image_path(object.hero_image)
          rescue => _ex
            nil
          end
        end
      end
    end
  end
end
