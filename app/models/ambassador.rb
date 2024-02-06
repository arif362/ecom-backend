class Ambassador < ApplicationRecord
  before_validation :format_phone_number
  belongs_to :user

  VALID_PHONE_NUMBER_REGEX = /\A(\+88)?(01)[13456789]\d{8}\z/
  validates :preferred_name, :bkash_number, presence: true
  validates :bkash_number, uniqueness: {scope: :is_deleted}, length: {is: 11}, format: {with: VALID_PHONE_NUMBER_REGEX} unless :is_deleted

  def self.remote_uniqueness_and_validation_check(content, field_name)
    if field_name == 'bkash_number'
      content = content.gsub(/\s|-/, "")
      ambassador = eval("Ambassador.find_by(#{field_name}: '#{content}', is_deleted: false)")
      return false if ambassador.present?
      return false unless content.match?(VALID_PHONE_NUMBER_REGEX)
    else
      return User.remote_uniqueness_and_validation_check(content, field_name)
    end
    true
  end

  private
  def format_phone_number
    if self.bkash_number.present?
      self.bkash_number = self.bkash_number.gsub(/\s|-/, "")
      self.bkash_number = self.bkash_number.last(11) if self.bkash_number.match?(VALID_PHONE_NUMBER_REGEX)
    end
  end
end
