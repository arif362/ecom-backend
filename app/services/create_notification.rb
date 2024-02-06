class CreateNotification
  include Interactor

  delegate :user,
           :notification,
           :message,
           :order,
           to: :context

  def call
    context.notification = Notification.new notification_attributes
    context.fail!(error: notification.errors.full_messages.to_sentence) unless notification.save!
  end

  private

  def notification_attributes
    {
      details: message,
      read: false,
      user_id: user.id,
      user_notifiable: order,
    }
  end
end
