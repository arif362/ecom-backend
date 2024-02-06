class UserModifyReason < ApplicationRecord
  audited
  has_many :user_modification_requests, dependent: :restrict_with_exception

  validates :title, :title_bn, :reason_type, presence: :true

  enum reason_type: { deactivated_or_deleted: 0, activated: 1 }

end
