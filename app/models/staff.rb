class Staff < ApplicationRecord
  devise :registerable,
         :database_authenticatable,
         :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtBlacklist

  has_many :permissions, dependent: :destroy
  belongs_to :warehouse, optional: true
  belongs_to :staffable, polymorphic: true, optional: true
  belongs_to :staff_role
  has_many :payments, as: :paymentable
  has_one :authorization_key, as: :authable, class_name: 'AuthorizationKey'
  has_many :third_party_logs, as: :user_able

  validates :first_name, :last_name, :email, :password, :password_confirmation, presence: true
  validates :email, uniqueness: true
  # TODO: Need to check warehouse if this staff is for central or FC warehouse.
  validate :warehouse_presence
  # TODO: After implementation unit enum, we will remove CustomerCareAgent table.
  #
  default_scope { where(is_active: true) }
  enum unit: { fulfilment_center: 0, central_warehouse: 1, customer_care: 2, finance: 3, dh_panel: 4, three_ps: 5 }

  accepts_nested_attributes_for :permissions, reject_if: :all_blank, allow_destroy: true, update_only: true

  def name
    "#{first_name} #{last_name}".strip
  end

  private

  def warehouse_presence
    fulfilment_center? || central_warehouse? ? warehouse.present? : true
  end
end
