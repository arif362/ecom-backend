module PushNotification
  class Android
    # A Service to send android notification using fcm
    require 'net/http'
    require 'fcm'

    include Interactor

    delegate :fcm_token,
             :title,
             :message,
             to: :context

    def call
      return unless fcm_token.present?

      url = URI(ENV['FCM_API_URL'])
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(url)
      request['content-type'] = 'application/json'
      request['Authorization'] = "key=#{ENV['FCM_KEY']}"
      request.body = {
        to: fcm_token,
        data: {
          title: title,
          body: message,
        }
      }.to_json

      http.request(request)
    end
  end
end