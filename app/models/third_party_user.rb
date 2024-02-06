class ThirdPartyUser < ApplicationRecord
  devise :registerable,
         :database_authenticatable,
         :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtBlacklist

  has_one :authorization_key, as: :authable, class_name: 'AuthorizationKey'
  has_many :staffs, as: :staffable, dependent: :destroy

  validates :name, :phone, :email, presence: true
  validates :email, :phone, uniqueness: true

  enum status: { active: 0, inactive: 1 }
  enum user_type: { others: 0, sno: 1, thanos: 2 }
end
