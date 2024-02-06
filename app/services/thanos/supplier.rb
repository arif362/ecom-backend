require 'uri'
require 'json'
require 'net/http'

module Thanos
  class Supplier
    def self.create(supplier)
      response = Thanos::Api.new('/res.partner', Thanos::Api::METHODS[:post], {
                                   name: supplier.supplier_name,
                                   phone: supplier.phone,
                                   email: supplier.email,
                                   is_company: true,
                                   unique_id: supplier.unique_id,
                                   code: supplier.id,
                                   is_supplier: true,
                                 }, Staff.unscoped.find_by(id: supplier.created_by_id)).call

      Rails.logger.info("THANOS create response for supplier_id, #{supplier.id}:  #{response}")
      response
    end

    def self.update(supplier)
      response = Thanos::Api.new("/res.partner/#{supplier.unique_id}",
                                 Thanos::Api::METHODS[:put], {
                                   name: supplier.supplier_name,
                                   phone: supplier.phone,
                                   email: supplier.email,
                                   is_company: true,
                                   unique_id: supplier.unique_id,
                                   code: supplier.id,
                                   is_supplier: true,
                                 }, Staff.unscoped.find_by(id: supplier.created_by_id)).call

      Rails.logger.info("THANOS update response for supplier_id, #{supplier.id}:  #{response}")
      response
    end
  end
end
