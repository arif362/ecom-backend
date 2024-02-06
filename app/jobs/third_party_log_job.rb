class ThirdPartyLogJob < ApplicationJob
  queue_as :default

  def perform(request, response, user, status)
    ThirdPartyLog.add_log(request, response, user, status)
  end
end
