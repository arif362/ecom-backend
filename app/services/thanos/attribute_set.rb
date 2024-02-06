require 'uri'
require 'json'
require 'net/http'

module Thanos
  class AttributeSet
    def self.create(attribute_set, prod_attrs_uniq_ids)
      response = Thanos::Api.new('/product.attribute.set', Thanos::Api::METHODS[:post], {
                                   'name' => attribute_set.title,
                                   'unique_id' => attribute_set.unique_id,
                                   'attribute_ids' => prod_attrs_uniq_ids,
                                 }, Staff.unscoped.find_by(id: attribute_set.created_by_id)).call
      Rails.logger.info("THANOS response for attribute_set_id, #{attribute_set.id}:  #{response}")
      response
    end

    def self.update(attribute_set, prod_attrs_uniq_ids)
      response = Thanos::Api.new("/product.attribute.set/#{attribute_set.unique_id}",
                                 Thanos::Api::METHODS[:put], {
                                   name: attribute_set.title,
                                   unique_id: attribute_set.unique_id,
                                   attribute_ids: prod_attrs_uniq_ids,
                                 }, Staff.unscoped.find_by(id: attribute_set.created_by_id)).call
      Rails.logger.info("THANOS response for attribute_set_id, #{attribute_set.id}:  #{response}")
      response
    end

    def self.delete(attribute_set, prod_attrs_uniq_ids)
      response = Thanos::Api.new("/product.attribute.set/#{attribute_set.unique_id}",
                                 Thanos::Api::METHODS[:delete], {
                                   name: attribute_set.title,
                                   unique_id: attribute_set.unique_id,
                                   attribute_ids: prod_attrs_uniq_ids,
                                 }, Staff.unscoped.find_by(id: attribute_set.created_by_id)).call
      Rails.logger.info("THANOS response for attribute_set_id, #{attribute_set.id}:  #{response}")
      response
    end
  end
end
