module CustomerCareReports
  class SubmitReport
    include Interactor

    delegate :order_id,
             :description,
             to: :context

    def call
      url = URI(ENV['IHELP_BD_URL'])
      http = Net::HTTP.new(url.host, url.port)
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(url)
      request['content-type'] = 'application/json'
      request.body =
        {
          order_id: order_id,
          order_description: description,
        }.to_json
      http.request(request)
    rescue => ex
      error!("IHELP BD report sumission error: #{ex.message}")
    end
  end
end
