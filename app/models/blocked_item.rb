require 'util'
class BlockedItem < ApplicationRecord
  audited
  ##################################
  # Associations
  ##################################
  belongs_to :warehouse
  belongs_to :variant
  has_many :stock_changes, as: :stock_changeable

  ##################################
  # Enumerable
  #################################
  enum status: { pending: 0, completed: 1 }
  enum blocked_reason: {
    product_is_expired: 0,
    product_is_damaged: 1,
    package_is_damaged: 2,
    seal_broken: 3,
    damaged_at_warehouse: 4,
    wrong_variant: 5,
    discontinue_the_sku: 6,
    temporarily_block: 7,
  }

  ###################################
  # Callbacks
  ###################################
  after_update :unblocked_garbage_process

  def unblocked_garbage_process
    if (garbage_quantity + unblocked_quantity) == blocked_quantity
      status = BlockedItem.statuses[:completed]
      self.update_column(:status, status)
    end
  end
end
