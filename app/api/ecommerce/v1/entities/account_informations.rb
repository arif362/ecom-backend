# frozen_string_literal: true

module Ecommerce
  module V1
    module Entities
      class AccountInformations < Grape::Entity
        include Ecommerce::V1::Helpers::ImageHelper

        expose :full_name
        expose :email
        expose :phone
        expose :gender
        expose :date_of_birth
        expose :created_at, as: :registered_at
        expose :images
        expose :addresses
        expose :favorite_stores
        expose :cart
        expose :whatsapp
        expose :viber
        expose :imo
        expose :preferred_name

        def images
          images_paths(object&.image)
        rescue ActiveStorage::FileNotFoundError
          {
            app_img: '',
            web_img: '',
          }
        end

        def full_name
          object.name
        end

        def addresses
          Ecommerce::V1::Entities::Address.represent(object&.addresses)
        end

        def favorite_stores
          Ecommerce::V1::Entities::FavoriteStores.represent(object&.favorite_stores, user: object)
        end

        def cart
          Ecommerce::V1::Entities::Carts.represent(object.cart,
                                                   list: true,
                                                   warehouse: options[:warehouse])
        end

        def preferred_name
          object&.ambassador&.preferred_name
        end
      end
    end
  end
end
