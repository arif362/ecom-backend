class CorporateUser < ApplicationRecord
  devise :database_authenticatable,
         :validatable
  validates :email, :password, :password_confirmation, presence: true, on: :create
  validates :email, uniqueness: true
  validates :password_confirmation, presence: true, on: :update, unless: -> { password.blank? }
end
