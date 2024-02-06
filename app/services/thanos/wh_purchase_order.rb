require 'uri'
require 'json'
require 'net/http'

module Thanos
  class WhPurchaseOrder
    def self.create(wh_purchase_order, line_items)
      response = Thanos::Api.new("/purchase/receive/#{wh_purchase_order.master_po_id}", Thanos::Api::METHODS[:post], {
                                   origin: wh_purchase_order.unique_id,
                                   receive_lines: line_items,
                                 }, Staff.unscoped.find_by(id: wh_purchase_order.created_by_id)).call
      Rails.logger.info("THANOS po create response:  #{response}")
      response
    end
  end
end
