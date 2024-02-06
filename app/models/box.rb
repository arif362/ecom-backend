class Box < ApplicationRecord
  audited
  belongs_to :dh_purchase_order, optional: true
  belongs_to :boxable, polymorphic: true
  has_many :box_line_items, dependent: :destroy
  has_many :line_items, through: :box_line_items

  enum status: { packed: 1, unpacked: 0 }

  default_scope { order('boxes.created_at DESC') }
end
