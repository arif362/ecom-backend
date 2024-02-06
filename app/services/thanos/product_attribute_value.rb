require 'uri'
require 'json'
require 'net/http'

module Thanos
  class ProductAttributeValue
    def self.create(product_attribute_value)
      response = Thanos::Api.new('/product.attribute.value', Thanos::Api::METHODS[:post], {
                                   'name' => product_attribute_value[:value],
                                   'unique_id' => product_attribute_value[:unique_id],
                                   'attribute_id' => product_attribute_value[:attribute_id],
                                 }, nil).call
      Rails.logger.info("THANOS create response for product_attribute_unique_id, #{product_attribute_value[:unique_id]}: #{response}")
      response
    end

    def self.update(product_attribute_value)
      response = Thanos::Api.new("/product.attribute.value/#{product_attribute_value[:unique_id]}",
                                 Thanos::Api::METHODS[:put], {
                                   'name' => product_attribute_value[:value],
                                   'unique_id' => product_attribute_value[:unique_id],
                                   'attribute_id' => product_attribute_value[:attribute_id],
                                 }, nil).call
      Rails.logger.info("THANOS update response for product_attribute_id, #{product_attribute_value[:id]}:  #{response}")
      response
    end

    def self.delete(product_attribute_value)
      response = Thanos::Api.new("/product.attribute.value/#{product_attribute_value.unique_id}",
                                 Thanos::Api::METHODS[:delete], {
                                   'name' => product_attribute_value.value,
                                   'unique_id' => product_attribute_value.unique_id,
                                   'attribute_id' => product_attribute_value.product_attribute&.unique_id,
                                 }, nil).call
      Rails.logger.info("THANOS delete response for product_attribute_id, #{product_attribute_value.id}:  #{response}")
      response
    end
  end
end
