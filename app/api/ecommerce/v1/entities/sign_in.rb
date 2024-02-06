module Ecommerce
  module V1
    module Entities
      class SignIn < Grape::Entity
        expose :token
        expose :full_name, as: :name
        expose :phone
        expose :cart
        expose :ambassador, merge: true

        def cart
          Ecommerce::V1::Entities::Carts.represent(object.cart,
                                                   list: options[:list],
                                                   warehouse: options[:warehouse])
        end

        def token
          options[:token]
        end

        def ambassador
          if object&.ambassador.present?
            return {
              is_ambassador: true,
              ambassador_name: object.ambassador&.preferred_name
            }
          end
          { is_ambassador: false }
        end
      end
    end
  end
end
