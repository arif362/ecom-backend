class OcProduct < ApplicationRecord
  has_many :oc_line_items
  has_many :company_assets
  belongs_to :root_category, class_name: 'OcCategory'
  belongs_to :leaf_category, class_name: 'OcCategory', optional: true
end
