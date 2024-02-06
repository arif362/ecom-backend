require 'uri'
require 'json'
require 'net/http'

module Thanos
  class ProductAttribute
    def self.create(product_attribute)
      response = Thanos::Api.new('/product.attribute', Thanos::Api::METHODS[:post], {
                                   'name' => product_attribute.name,
                                   'unique_id' => product_attribute.unique_id,
                                 }, Staff.unscoped.find_by(id: product_attribute.created_by_id)).call
      Rails.logger.info("THANOS create response for product_attribute_id, #{product_attribute.id}:  #{response}")
      response
    end

    def self.update(product_attribute)
      response = Thanos::Api.new("/product.attribute/#{product_attribute[:unique_id]}",
                                 Thanos::Api::METHODS[:put], {
                                   'name' => product_attribute[:name],
                                   'unique_id' => product_attribute[:unique_id],
                                 }, Staff.unscoped.find_by(id: product_attribute[:created_by_id])).call
      Rails.logger.info("THANOS update response for product_attribute_id, #{product_attribute[:id]}:  #{response}")
      response
    end

    def self.delete(product_attribute)
      response = Thanos::Api.new("/product.attribute/#{product_attribute.unique_id}",
                                 Thanos::Api::METHODS[:delete], {
                                   'name' => product_attribute.name,
                                   'unique_id' => product_attribute.unique_id,
                                 }, Staff.unscoped.find_by(id: product_attribute.created_by_id)).call
      Rails.logger.info("THANOS delete response for product_attribute_id, #{product_attribute.id}:  #{response}")
      response
    end
  end
end
