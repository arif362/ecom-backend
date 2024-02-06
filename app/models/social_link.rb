class SocialLink < ApplicationRecord
  ####################################
  # validation
  ####################################
  validates :name, :url, presence: true
  validates :name, :url, uniqueness: true
end
