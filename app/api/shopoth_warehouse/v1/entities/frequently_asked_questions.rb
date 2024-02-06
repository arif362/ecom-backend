module ShopothWarehouse
  module V1
    module Entities
      class FrequentlyAskedQuestions < Grape::Entity
        expose :id
        expose :question
        expose :bn_question
        expose :answer
        expose :bn_answer
        expose :product_id
      end
    end
  end
end
