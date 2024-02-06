class CustomerDeviceUser < ApplicationRecord
  belongs_to :user
  belongs_to :customer_device
end
