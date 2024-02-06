class UserModificationRequest < ApplicationRecord
  audited
  belongs_to :user
  belongs_to :user_modify_reason

  before_create :check_status_validation_on_create
  before_save :check_status_validation_on_save, if: :will_save_change_to_status?
  after_save :send_mail

  validates :request_type, :status, presence: true

  enum request_type: { activated: 0, deactivated: 1, deleted: 2 }
  enum status: { pending: 0, approved: 1, rejected: 2 }

  def self.create_by_customer_care(params)
    request = nil
    ActiveRecord::Base.transaction do
      request = create!(params.merge(status: 'approved'))
      if request.activated?
        request.user.update!(status: :active)
      elsif request.deactivated?
        request.user.update!(status: :inactive)
      elsif request.deleted?
        request.user.update!(is_deleted: true)
      end
    end
    request
  end

  def approved!
    ActiveRecord::Base.transaction do
      if activated?
        fail 'user is already active' if user.active?
        user.update!(status: :active)
      elsif deactivated?
        fail 'user is already inactive' if user.inactive?
        user.update!(status: :inactive)
      else
        user.update!(is_deleted: true)
      end
      update!(status: :approved)
    end
  end

  def rejected!
    update!(status: :rejected)
  end

  private
  def check_status_validation_on_create
    fail "user is already inactive" if (activated? && user.active?) || (deactivated? && user.inactive?)
  end

  def check_status_validation_on_save
    fail "status not permitted to change from #{status_in_database}" unless status_in_database == 'pending'
  end

  def send_mail
    NotificationMailer.notify(user.email, request_type, status, user.name).deliver_now if user.email.present?
  end
end
