class CustomerCareAgent < ApplicationRecord
  devise :database_authenticatable,
         :validatable

  validates :email, :password, :password_confirmation, presence: true, on: :create
  validates :email, uniqueness: true
  validates :password_confirmation, presence: true, on: :update, unless: -> { password.blank? }

  has_one :address, as: :addressable
  has_many :placed_return_orders, as: :return_orderable, class_name: 'ReturnCustomerOrder'
  has_many :staffs, as: :staffable, dependent: :destroy

  has_one :authorization_key, as: :authable, class_name: 'AuthorizationKey'

  enum status: { active: 0, inactive: 1 }

  default_scope { where(is_active: true ) }
end
