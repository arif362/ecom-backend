class BankAccount < ApplicationRecord
  audited
  belongs_to :ownerable, polymorphic: true
  has_many :credit_bank_transactions, class_name: 'BankTransaction', dependent: :restrict_with_exception
  has_many :debit_bank_transactions, class_name: 'BankTransaction', dependent: :restrict_with_exception

  validates :account_number, uniqueness: true
end
