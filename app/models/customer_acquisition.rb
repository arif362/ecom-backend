class CustomerAcquisition < ApplicationRecord
  belongs_to :registered_by, polymorphic: true
  belongs_to :user
  belongs_to :coupon, optional: true

  validates :amount, :coupon, presence: true, if: -> { coupon.present? }
  validates :information_status, presence: true

  enum information_status: {incomplete: 0, half: 1, full: 2}

  def self.add_acquisition(params, current_user, locale = 'en')
    I18n.locale = locale
    params[:password] = SecureRandom.alphanumeric(6)
    params[:password_confirmation] = params[:password]
    user = User.find_by(phone: params[:phone])
    fail StandardError, I18n.t('common.errors.messages.user_already_exist') if user and user&.is_otp_verified

    ActiveRecord::Base.transaction do
      if user
        user.update!(params.merge(registerable: current_user).except(:preferred_name))
      else
        user = User.create!(params.merge(registerable: current_user).except(:preferred_name))
      end
      user.update!(otp: rand(10_000..99_999))
      message = "To complete the Shopoth customer registration process, verify with the OTP: #{user.otp}."
      message = "শপথ গ্রাহক রেজিস্ট্রেশন প্রক্রিয়া সম্পূর্ণ করতে, OTP দিয়ে যাচাই করুন: #{user.otp}।" if locale == 'bn'
      if current_user&.class&.name == 'User'
        current_user&.ambassador&.update_columns(preferred_name: params[:preferred_name]) if params[:preferred_name].present?
        message = "“#{current_user&.ambassador&.preferred_name || current_user&.full_name}”, an ambassador of Shopoth, is requesting you to join Shopoth. Please share the provided OTP to your ambassador, to become a Shopoth user. OTP: #{user.otp}"
        if locale == 'bn'
          message = "“#{current_user&.ambassador&.preferred_name || current_user&.full_name}”, এর একজন অ্যাম্বাসেডর, আপনাকে শপথ-এ যোগদানের জন্য অনুরোধ করছেন। অনুগ্রহ করে আপনার অ্যাম্বাসেডরের সাথে প্রদত্ত OTP শেয়ার করুন, একজন শপথ ব্যবহারকারী হতে। OTP: #{user.otp}"
        end
      end
      CustomerAcquisitionSmsJob.perform_later(params[:phone], message)
    end
    {
      user_id: user&.id,
      user_phone: user&.phone,
      user_name: user&.full_name
    }
  end

  def self.verify_otp(otp, customer, current_user, locale)
    I18n.locale = locale
    fail StandardError, I18n.t('common.errors.messages.otp_already_verified') if customer&.is_otp_verified
    fail StandardError, I18n.t('common.errors.messages.incorrect_otp') unless customer&.otp == otp

    password = SecureRandom.alphanumeric(6)
    ActiveRecord::Base.transaction do
      customer.update!(is_otp_verified: true, verifiable: current_user, verified_at: Time.now, password: password, password_confirmation: password)
      current_user.customer_acquisitions.create!(user: customer, information_status: :incomplete)
      message = "Your registration is successful. Your Shopoth User ID is #{customer.phone} and an auto-generated password is (#{password}). Please login to your account and change the password as you like."
      if locale == 'bn'
        message = "আপনার রেজিস্ট্রেশন সফল হয়েছে. আপনার শপথ ইউজার আইডি হল #{customer.phone} এবং একটি স্বয়ংক্রিয় পাসওয়ার্ড হল (#{password})। অনুগ্রহ করে আপনার অ্যাকাউন্টে লগইন করুন এবং আপনার পছন্দ মতো পাসওয়ার্ড পরিবর্তন করুন"
      end
      CustomerAcquisitionSmsJob.perform_later(customer.phone, message)
    end
  end

  def send_greetings(current_user, locale = 'en')
    I18n.locale = locale
    fail StandardError, I18n.t('common.errors.messages.otp_not_verified') unless user&.is_otp_verified
    fail StandardError, I18n.t('common.errors.messages.greetings_not_allowed') unless current_user&.id == registered_by_id and current_user&.id == user&.verifiable_id
    fail StandardError, I18n.t('common.errors.messages.registration_already_completed') if coupon.present? and amount.present?

    update!(amount: 20, information_status: :half)
    send_registration_notification(current_user, locale)
    send_greetings_notification(current_user, 20, locale) if Coupon.first_registration&.active&.last&.running?
  end

  def update_additional_info(params, current_user, locale = 'en')
    I18n.locale = locale
    fail StandardError, I18n.t('common.errors.messages.otp_not_verified') unless user&.is_otp_verified
    fail StandardError, I18n.t('common.errors.messages.greetings_not_allowed') unless current_user&.id == registered_by_id and current_user&.id == user&.verifiable_id
    fail StandardError, I18n.t('common.errors.messages.registration_already_completed') if coupon.present? and amount.present?
    fail StandardError, I18n.t('common.errors.messages.min_1_social_required') if params[:whatsapp].blank? and params[:viber].blank? and params[:imo].blank?
    fail StandardError, I18n.t('common.errors.messages.whatsapp_nid_imo_length', social_account: I18n.t('common.social_account.whatsapp')) if params[:whatsapp].present? and params[:whatsapp].to_s.length < 6
    fail StandardError, I18n.t('common.errors.messages.whatsapp_nid_imo_length', social_account: I18n.t('common.social_account.imo')) if params[:imo].present? and params[:imo].to_s.length < 6
    fail StandardError, I18n.t('common.errors.messages.whatsapp_nid_imo_length', social_account: I18n.t('common.social_account.viber')) if params[:viber].present? and params[:viber].to_s.length < 6
    fail StandardError, I18n.t('common.errors.messages.whatsapp_nid_imo_uniqueness', social_account: I18n.t('common.social_account.whatsapp')) if params[:whatsapp].present? &&
      User.find_by(whatsapp: params[:whatsapp], is_otp_verified: true, status: :active, is_deleted: [false, nil]).present?
    fail StandardError, I18n.t('common.errors.messages.whatsapp_nid_imo_uniqueness', social_account: I18n.t('common.social_account.imo')) if params[:imo].present? &&
      User.find_by(imo: params[:imo], is_otp_verified: true, status: :active, is_deleted: [false, nil]).present?
    fail StandardError, I18n.t('common.errors.messages.whatsapp_nid_imo_uniqueness', social_account: I18n.t('common.social_account.viber')) if params[:viber].present? &&
      User.find_by(viber: params[:viber], is_otp_verified: true, status: :active, is_deleted: [false, nil]).present?
    fail StandardError, I18n.t('common.errors.messages.user_home_address_length') if params[:home_address].present? and params[:home_address].to_s.length < 15
    fail StandardError, I18n.t('common.errors.messages.user_nid_length') if params[:nid].present? and (params[:nid].to_s.length < 10 || params[:nid].to_s.length > 17)

    ActiveRecord::Base.transaction do
      user&.update!(params)
      coupon = Coupon.create!(usable: user,
                              discount_type: :percentage,
                              max_limit: 200,
                              discount_amount: 15,
                              coupon_type: :acquisition,
                              code: SecureRandom.alphanumeric(6).upcase)
      update!(amount: 30, coupon: coupon, information_status: :full)
      message = "Congratulations ! As a new Shopoth user you can avail a 15% discount voucher up to 200 BDT for first order. Your voucher code: #{coupon.code}"
      message = "অভিনন্দন! একজন নতুন Shopoth ব্যবহারকারী হিসেবে, আপনি পাচ্ছেন ৳২০০ পর্যন্ত ১৫% ডিসকাউন্ট ভাউচার প্রথম অর্ডারের জন্য। আপনার ভাউচার কোডঃ #{coupon.code.to_bn}" if locale == 'bn'
      CustomerAcquisitionSmsJob.perform_later(user&.phone, message)
    end
    send_registration_notification(current_user, locale)
    send_greetings_notification(current_user, 30, locale)
  end

  private
  def send_registration_notification(current_user, locale)
    successful_register_hash = {
      app_user: current_user,
      title: 'Successful customer registration',
      bn_title: 'সফল গ্রাহক রেজিস্ট্রেশন',
      message: "“#{user&.full_name}“ has been successfully registered through your reference",
      bn_message: "আপনার সুপারিশে “#{user&.full_name}“ সফলভাবে রেজিস্ট্রেশন করেছেন।",
    }
    successful_register_hash = set_notification_attributes(successful_register_hash, locale)

    if current_user&.class&.name == 'Partner'
      PushNotification::CreateAppNotificationsPartner.call(**successful_register_hash)
      Rails.logger.info 'Successfully Notified Partner.'
    elsif current_user&.class&.name == 'RouteDevice'
      successful_register_hash[:app_user] = current_user&.route
      PushNotification::CreateAppNotifications.call(**successful_register_hash)
      Rails.logger.info 'Successfully Notified SR.'
    elsif current_user&.class&.name == 'User'
      successful_register_hash = {
        app_user: successful_register_hash[:app_user],
        details: successful_register_hash[:message],
        bn_details: successful_register_hash[:bn_message],
      }
      successful_register_hash[:attributes] = locale == 'en' ?
                                                { title: 'Congratulations!', details: successful_register_hash[:details] } :
                                                { title: 'অভিনন্দন!', details: successful_register_hash[:bn_details] }
      PushNotification::CreateEcomNotifications.call(**successful_register_hash)
      Rails.logger.info 'Successfully Notified Ambassador.'
    end
  end

  def send_greetings_notification(current_user, amount, locale)
    greetings_notification_hash = {
      app_user: current_user,
      title: 'Congratulations!',
      bn_title: 'অভিনন্দন!',
      message: "You have earned #{amount} BDT for successful registration of customer",
      bn_message: "আপনি নতুন কাস্টমার রেজিস্ট্রেশন করে ৳#{amount.to_bn} পুরষ্কার পেয়েছেন",
    }
    greetings_notification_hash = set_notification_attributes(greetings_notification_hash, locale)

    if current_user&.class&.name == 'Partner'
      PushNotification::CreateAppNotificationsPartner.call(**greetings_notification_hash)
      Rails.logger.info 'Successfully Notified Partner.'
    elsif current_user&.class&.name == 'RouteDevice'
      greetings_notification_hash[:app_user] = current_user&.route
      PushNotification::CreateAppNotifications.call(**greetings_notification_hash)
      Rails.logger.info 'Successfully Notified SR.'
    elsif current_user&.class&.name == 'User'
      greetings_notification_hash = {
        app_user: greetings_notification_hash[:app_user],
        details: greetings_notification_hash[:message],
        bn_details: greetings_notification_hash[:bn_message],
      }
      greetings_notification_hash[:attributes] = locale == 'en' ?
                                                   { title: 'Congratulations!', details: greetings_notification_hash[:details] } :
                                                   { title: 'অভিনন্দন!', details: greetings_notification_hash[:bn_details] }
      PushNotification::CreateEcomNotifications.call(**greetings_notification_hash)
      Rails.logger.info 'Successfully Notified Ambassador.'
    end
  end

  def set_notification_attributes(hash, locale)
    hash[:attributes] = locale == 'en' ? { title: hash[:title], message: hash[:message] } :
                          { title: hash[:bn_title], message: hash[:bn_message] }
    hash
  end
end
