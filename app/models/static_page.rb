class StaticPage < ApplicationRecord
  has_one :meta_datum, as: :metable, class_name: 'MetaDatum', dependent: :destroy

  enum page_type: { home_page: 0, sign_in_page: 1, sign_up_page: 2, contact_us_page: 3 }

  validates :page_type, presence: true, uniqueness: true

  accepts_nested_attributes_for :meta_datum, reject_if: :all_blank, allow_destroy: true
end
