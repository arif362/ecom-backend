# frozen_string_literal: true

class Supplier < ApplicationRecord
  audited
  belongs_to :staff, optional: true
  has_one :address, as: :addressable, dependent: :destroy
  # has_many :dh_purchase_orders
  has_many :wh_purchase_orders
  has_many :suppliers_variants, dependent: :destroy
  has_many :variants, through: :suppliers_variants
  # has_many :pick_up_locations, class_name: "Address"
  has_many :bank_accounts, as: :ownerable, dependent: :restrict_with_exception
  has_many :bank_transaction_receives, as: :transactionable_to, dependent: :restrict_with_exception
  has_many :supplier_variant_changes

  validates :unique_id, uniqueness: true
  # validates :company, presence: true

  accepts_nested_attributes_for :address, allow_destroy: true

  enum status: %i(unavailable available)

  before_save :set_status
  before_create :assign_unique_id, :call_3ps_create_api
  before_update :call_3ps_update_api

  default_scope { where(is_deleted: false) }
  default_scope { order('id DESC') }
  scope :search_by_name, ->(name) { where(['LOWER(supplier_name) LIKE ?', "%#{name.downcase}%"]) }

  def set_status
    self.status = 1 if self.status.nil?
  end

  def assign_unique_id
    self.unique_id = SecureRandom.uuid
  end

  def call_3ps_create_api
    response = Thanos::Supplier.create(self)
    return unless response[:error].present?

    e = errors.add(:base, (response[:error_descrip]).to_s)
    fail StandardError, e.to_s
  end

  def call_3ps_update_api
    response = Thanos::Supplier.update(self)
    return unless response[:error].present?

    e = errors.add(:base, (response[:error_descrip]).to_s)
    fail StandardError, e.to_s
  end
end
