require 'uri'
require 'json'
require 'net/http'

module Thanos
  class Category
    def self.create(category)
      response = Thanos::Api.new('/product.category', Thanos::Api::METHODS[:post], {
                                   'name' => category.title,
                                   'parent_id' => category.parent&.unique_id,
                                   'gm_per_auto_approval' => 0,
                                   'unique_id' => category.unique_id,
                                 }, Staff.unscoped.find_by(id: category.created_by_id)).call
      Rails.logger.info("THANOS create response for category_id, #{category.id}:  #{response}")
      response
    end

    def self.update(category)
      response = Thanos::Api.new("/product.category/#{category.unique_id}",
                                 Thanos::Api::METHODS[:put], {
                                   'name' => category.title,
                                   'parent_id' => category.parent&.unique_id,
                                   'gm_per_auto_approval' => 0,
                                   'unique_id' => category.unique_id,
                                 }, Staff.unscoped.find_by(id: category.created_by_id)).call
      Rails.logger.info("THANOS update response for category_id, #{category.id}:  #{response}")
      response
    end

    def self.delete(category)
      response = Thanos::Api.new("/product.category/#{category.unique_id}",
                                 Thanos::Api::METHODS[:delete], {
                                   'name' => category.title,
                                   'parent_id' => category.parent&.unique_id,
                                   'gm_per_auto_approval' => 0,
                                   'unique_id' => category.unique_id,
                                 }, Staff.unscoped.find_by(id: category.created_by_id)).call
      Rails.logger.info("THANOS delete response for category_id, #{category.id}:  #{response}")
      response
    end
  end
end
