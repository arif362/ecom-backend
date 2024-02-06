require 'uri'
require 'json'
require 'net/http'

module Thanos
  class Api
    METHODS = {
      get: Net::HTTP::Get,
      post: Net::HTTP::Post,
      put: Net::HTTP::Put,
      delete: Net::HTTP::Delete,
    }.freeze

    # @param [String] url
    # @param [Thanos::METHOD] http_method
    # @param [Hash] params
    # @return [Void]
    def initialize(url, http_method, params, user)
      @url = url
      @http_method = http_method
      @params = params
      @user = user
    end

    def call
      api(@url, @http_method, true, @params, @user)
    end

    private

    # @param [String] url
    # @param [Thanos::METHOD] http_method
    # @param [Boolean] authorization
    # @param [Hash] params
    # @return [Hash{Symbol->String}]
    def api(url, http_method, authorization, params, user)
      return { error: '`http_method` parameter type have to Thanos::Api::METHODS' } unless METHODS.value?(http_method)

      uri = URI("#{ENV['THANOS_BASE_URL']}#{url}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = http_method.new(uri)
      request['Content-Type'] = 'text/plain'
      request['Access-Token'] = get_access_token if authorization
      request.body = params.to_json
      response = http.request(request).read_body
      Rails.logger.info("THANOS api response: #{response}")

      ThirdPartyLogJob.perform_later("body: #{request.body}",
                                     response,
                                     user,
                                     request[:error] != true)
      JSON.parse(response, symbolize_names: true)
    end

    def get_access_token
      response = api('/auth/get_tokens', Thanos::Api::METHODS[:post], false, {
                       'username' => (ENV['THANOS_APP_USER_NAME']).to_s,
                       'password' => (ENV['THANOS_APP_USER_PASSWORD']).to_s,
                     }, @user)
      response[:access_token]
    end
  end
end
