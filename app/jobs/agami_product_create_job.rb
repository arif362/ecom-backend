class AgamiProductCreateJob < ApplicationJob
  queue_as :default
  require 'uri'
  require 'net/http'

  def perform(product)
    agami_url = ENV["AGAMI_BASE_URL"]
    uri = URI("#{agami_url}/api/v1/products")
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = product
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
  end
end
