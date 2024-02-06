class UserPreference < ApplicationRecord
  ###############
  # Associations
  ###############
  belongs_to :user

  ###############
  # Enumerable
  ###############
  enum default_delivery_method: { cod: 0,
                                  default_pickup_point: 1,
                                  home_delivery: 2 }
  enum mail_notification: {email: 0, no_email: 1}
  enum smart_notification: {push: 0, no_push: 1}
  enum cellular_notification: {sms: 0, no_sms: 1}
  enum subscription: {newsletter: 0, no_newsletter: 1}
end
