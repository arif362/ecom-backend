module Ecommerce
  module V1
    module Entities
      class Campaigns < Grape::Entity

        expose :id
        expose :title
        expose :title_bn
        expose :page_url
      end
    end
  end
end
