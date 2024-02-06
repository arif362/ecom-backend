class Questionnaire < ApplicationRecord
  enum questionnaire_type: {
    Inbound: 0,
    Return: 1,
  }
  belongs_to :category, optional: true

  validates :question, presence: true
end
