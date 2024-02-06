require 'uri'
require 'json'
require 'net/http'

module Thanos
  class Brand
    def self.create(brand)
      response = Thanos::Api.new('/agami.brand', Thanos::Api::METHODS[:post], {
                                   'name' => brand.name,
                                   'unique_id' => brand.unique_id,
                                 }, Staff.unscoped.find_by(id: brand.created_by_id)).call
      Rails.logger.info("THANOS create response for category_id, #{brand.id}:  #{response}")
      response
    end

    def self.update(brand)
      response = Thanos::Api.new("/agami.brand/#{brand.unique_id}",
                                 Thanos::Api::METHODS[:put], {
                                   'name' => brand.name,
                                   'unique_id' => brand.unique_id,
                                 }, Staff.unscoped.find_by(id: brand.created_by_id)).call
      Rails.logger.info("THANOS update response for category_id, #{brand.id}:  #{response}")
      response
    end

    def self.delete(brand)
      response = Thanos::Api.new("/agami.brand/#{brand.unique_id}",
                                 Thanos::Api::METHODS[:delete], {
                                   'name' => brand.name,
                                   'unique_id' => brand.unique_id,
                                 }, Staff.unscoped.find_by(id: brand.created_by_id)).call
      Rails.logger.info("THANOS update response for category_id, #{brand.id}:  #{response}")
      response
    end
  end
end
