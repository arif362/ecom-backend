class RaCoupon < ApplicationRecord
  # belongs_to :retailer_assistant
  # belongs_to :promotion

  ###########################
  # Callbacks
  ###########################
  before_create :generate_unique_id

  ###########################
  # Validations
  ###########################
  validates :code, uniqueness: true

  def generate_unique_id
    code = (SecureRandom.random_number(9e5)+ 1e5).to_i.to_s
    self.code = code
  end
end
