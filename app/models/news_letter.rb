class NewsLetter < ApplicationRecord
  has_secure_token
  has_secure_token :token
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
