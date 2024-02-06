module Ecommerce
  module V1
    module Entities
      class UserModifyReasons < Grape::Entity
        expose :id
        expose :title
        expose :title_bn
      end
    end
  end
end
