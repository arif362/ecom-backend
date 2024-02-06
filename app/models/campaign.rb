class Campaign < ApplicationRecord
  audited
  belongs_to :campaignable, polymorphic: true
end
