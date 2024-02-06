module RecommendationEngine
  class LearnNewData
    def initialize(clear_all = false)
      @clear_all = clear_all
    end

    def call
      clean_all_data if @clear_all

      add_category_product_relations
      add_customer_order_product_relations
      # add_review_product_relations
      add_brand_product_relations
    end

    private

    def recommender
      @recommender ||= ProductRecommender.new
    end

    # Something crazy has happened, so let's just start fresh and wipe out all previously stored similarities:
    def clean_all_data
      recommender.clean!
    end

    def add_category_product_relations
      Category.all.each do |category|
        add_product_ids_to_input_matrix(:categories,
                                        "category-#{category.id}",
                                        'product',
                                        category.product_ids)
      end
    end

    def add_brand_product_relations
      Brand.all.each do |brand|
        add_product_ids_to_input_matrix(:brands,
                                        "brand-#{brand.id}",
                                        'brand',
                                        brand.products.pluck(:id))
      end
    end

    def add_customer_order_product_relations
      CustomerOrder.all.each do |order|
        product_ids = order.shopoth_line_items.map do |item| item&.variant&.product_id end

        add_product_ids_to_input_matrix(:customer_orders,
                                        "customer-order-#{order.id}",
                                        'customer-order-for',
                                        product_ids.compact)
      end
    end

    def add_review_product_relations
      reviews = Review.where(reviewable_type: 'Variant').distinct do |review| review&.reviewable.&product_id end
      reviews.group_by(&:rating).each do |rating, review_list|
        product_ids = review_list.map do |review_item| review_item&.reviewable&.product_id end

        add_product_ids_to_review_matrix(:reviews,
                                         "rating-#{rating}",
                                         "rating-#{rating}",
                                         product_ids.compact)
      end
    end

    def add_product_ids_to_input_matrix(input_matrix, source_identifier, recommendation_tag, product_ids)
      product_ids.in_groups_of(100, false) do |batch_product_ids|
        target_ids = batch_product_ids.map { |product_id| "#{recommendation_tag}-#{product_id}" }
        recommender.add_to_matrix(input_matrix, source_identifier, target_ids)
      end
    end

    def add_product_ids_to_review_matrix(input_matrix, source_identifier, recommendation_tag, product_ids)
      index = 0
      product_ids.in_groups_of(100, false) do |batch_product_ids|
        target_ids = batch_product_ids.append(batch_product_ids[0]).map { |product_id| "#{recommendation_tag}-#{index += 1}#{product_id}" }
        recommender.add_to_matrix(input_matrix, source_identifier, target_ids)
      end
    end
  end
end
