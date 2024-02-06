class CustomerDevice < ApplicationRecord
  has_many :customer_device_users
  has_many :users, through: :customer_device_users

  validates :device_id, :device_model, :device_os_type, :device_os_version, :fcm_id, presence: true
  validates :device_id, :fcm_id, uniqueness: true
end
