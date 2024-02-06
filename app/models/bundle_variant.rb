class BundleVariant < ApplicationRecord
  audited
  belongs_to :bundle
  belongs_to :variant
end
