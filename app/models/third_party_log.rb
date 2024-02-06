class ThirdPartyLog < ApplicationRecord
  belongs_to :user_able, polymorphic: true, optional: true

  def self.add_log(request, response, user_able, status = nil)
    create(api_response: response,
           api_request: request,
           user_able: user_able,
           status: status)
  end
end
