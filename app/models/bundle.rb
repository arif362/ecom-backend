class Bundle < ApplicationRecord
  audited
  belongs_to :variant
  has_many :bundle_variants, dependent: :destroy
  has_many :warehouse_bundles, dependent: :destroy
end
