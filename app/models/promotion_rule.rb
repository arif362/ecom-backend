class PromotionRule < ApplicationRecord
  belongs_to :promotion

  ###########################
  ####### Validation ########
  ###########################
  validate :restrict_negative_value

  private

  def restrict_negative_value
    errors.add(:value, "can't be negative.") if value.negative?
  end
end
