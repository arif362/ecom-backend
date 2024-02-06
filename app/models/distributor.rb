class Distributor < ApplicationRecord
  audited
  ####################################
  ############ Validations ###########
  ####################################
  validates :name, :bn_name, :phone, presence: true, uniqueness: true
  validates :email, format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/ }, presence: true, uniqueness: true

  ####################################
  ########### Associations ###########
  ####################################
  belongs_to :warehouse
  has_many :staffs, as: :staffable, dependent: :destroy
  has_many :riders, dependent: :restrict_with_exception
  has_many :routes, dependent: :restrict_with_exception
  has_many :partners, through: :routes, dependent: :restrict_with_exception
  has_many :retailer_assistants, dependent: :restrict_with_exception
  has_many :return_customer_orders, dependent: :restrict_with_exception
  has_many :customer_orders, dependent: :restrict_with_exception
  has_many :bank_accounts, as: :ownerable, dependent: :restrict_with_exception
  has_many :bank_transaction_payments, as: :transactionable_by, dependent: :restrict_with_exception
  has_many :bank_transaction_receives, as: :transactionable_to, dependent: :restrict_with_exception
  has_many :distributor_margins, dependent: :restrict_with_exception
  has_many :month_wise_payment_histories, dependent: :restrict_with_exception
  has_many :thanas, dependent: :restrict_with_exception
  has_many :challans, dependent: :restrict_with_exception
  has_many :return_challans, dependent: :restrict_with_exception
  has_many :aggregate_returns

  ####################################
  ############ Enumerable ############
  ####################################
  enum status: { active: 0, inactive: 1 }

  def valid?(password)
    staff = staffs.find_by(email: email, unit: 'dh_panel')
    return { success: false, error: 'Distributor admin not found for this email.' } unless staff
    return { success: false, error: "Distributor isn't active." } unless staff.staffable.active?
    unless staff.valid_password?("dh_admin#{password}")
      return { success: false, error: 'Password not matched.' }
    end

    { success: true, error: '', staff: staff }
  end

  #####################################
  ########### Class Methods ###########
  #####################################
  def self.password(password)
    "dh_admin#{password}"
  end
end
