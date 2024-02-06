class Contact < ApplicationRecord
  # validation
  validates :name, presence: true, format: { with: /\A[a-zA-Z\s.]+\z/ }
  validates :email, presence: true, format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/ }
  validates :phone, presence: true
  validates :message, presence: true

  def self.search_by_email(params = '')
    where('email = ?', params.downcase)
  end

  def self.search_by_phone(params = '')
    where('phone = ?', params.downcase)
  end
end
