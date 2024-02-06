module RecommendationEngine
  class ProcessMatrixRecalc
    def initialize(process_all = false)
      @process_all = process_all
    end

    def call
      if @process_all
        process_all!
      else
        process_selected_samples_only!
      end
    end

    private

    def recommender
      @recommender ||= ProductRecommender.new
    end

    def process_all!
      Rails.logger.info 'PROCCESSING ALL ITEMS - CAN BE SLOW'
      recommender.process!
    end

    def process_selected_samples_only!
      Rails.logger.info 'PROCCESSING PRODUCT SELECTION'

      total_items = Product.all.count
      estimated_batches = total_items / 50

      Rails.logger.warn 'PROCESSING IS LIMITED TO 1000 RECORDS ONLY !!!!'

      Product.all.limit(1000).select(:id).find_in_batches(batch_size: 50).with_index do |group, batch|
        Rails.logger.info "processing batch: #{batch}/#{estimated_batches}"

        product_ids = group.map(&:id)
        Rails.logger.debug "process PRODUCTS: #{product_ids}"
        # TODO: update the timestamp last_recommender_processed_at on all items !!

        process_list = product_ids.map { |item_id| "item-#{item_id}" }
        Rails.logger.debug "process: #{process_list}"

        # calculate the recommendations for this item
        recommender.process_items!(process_list)
      end
    end
  end
end
