class MetaDatum < ApplicationRecord
  audited
  belongs_to :metable, polymorphic: true
end
