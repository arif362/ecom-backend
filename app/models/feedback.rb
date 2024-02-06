class Feedback < ApplicationRecord
  # association
  belongs_to :user

  # validation
  validates :message, :rating, presence: true
  validates_inclusion_of :rating, in: 1..5
end
