module RecommendationEngine
  class ProductRecommender
    include Predictor::Base

    limit_similarities_to 50

    # Use Sorenson over Jaccard
    input_matrix :categories, weight: 1, measure: :sorensen_coefficient

    input_matrix :brands, weight: 2, measure: :sorensen_coefficient

    input_matrix :customer_orders, weight: 3

    input_matrix :reviews, weight: 4
  end
end