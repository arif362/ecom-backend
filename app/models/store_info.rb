class StoreInfo < ApplicationRecord
  ####################################
  # validation
  ####################################
  validates :contact_address, :official_email, presence: true
  validates :contact_number, presence: true,
                             numericality: true
end
