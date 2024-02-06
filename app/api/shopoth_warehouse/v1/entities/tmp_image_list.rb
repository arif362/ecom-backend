module ShopothWarehouse
  module V1
    module Entities
      class TmpImageList < Grape::Entity
        include ShopothWarehouse::V1::Helpers::ImageHelper

        expose :id
        expose :file_name
        expose :image

        def image
          image_path(object&.image)
        rescue ActiveStorage::FileNotFoundError
          nil
        end
      end
    end
  end
end
