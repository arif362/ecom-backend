class JsonWebToken
  def self.encode(payload)
    expiration = 1.year.from_now.to_i
    JWT.encode payload.merge(exp: expiration), Rails.application.secret_key_base
  end

  def self.decode(token)
    JWT.decode(token, Rails.application.secret_key_base).first
  end

  def self.remove_token(bearer_token = '')
    auth_key = AuthorizationKey.find_by(token: bearer_token)
    auth_key.destroy! if auth_key.present?
    auth_key&.destroyed? || false
  end

  def self.user_token_encode(user)
    expiry = 3.month.from_now
    rand = SecureRandom.hex(10)
    hash = BCrypt::Password.create(rand)
    token = JWT.encode hash, Rails.application.secret_key_base

    auth_key = AuthorizationKey.find_or_create_by(authable: user) do |auth|
      auth.otp = user.otp
      auth.token = token
      auth.expiry = expiry
    end
    auth_key.update!(token: token, expiry: expiry)
    auth_key.token
  end

  def self.login_token_encode(object)
    expiry = 1.week.from_now
    hash = BCrypt::Password.create(SecureRandom.hex(10))
    token = JWT.encode((hash + Time.now.to_s), Rails.application.secret_key_base)
    auth_key = AuthorizationKey.find_or_create_by(authable: object)
    auth_key.update!(token: token, expiry: expiry)
    auth_key.token
  end

  def self.single_login_token_encode(user)
    expiry = 3.month.from_now
    rand = SecureRandom.hex(10)
    hash = BCrypt::Password.create(rand)
    token = JWT.encode hash, Rails.application.secret_key_base
    auth_key = AuthorizationKey.find_or_create_by(authable: user)
    auth_key.update!(token: token, expiry: expiry)
    auth_key.token
  end

  def self.encode_otp(user)
    new_auth_key = new_auth_key(user)
    send_otp(new_auth_key, user)
  end

  def self.verify_otp(token, otp)
    auth_key = AuthorizationKey.find_by(token: token)
    if auth_key.present? && auth_key.otp == otp
      auth_key
    else
      false
    end
  end

  def self.new_auth_key(user)
    token_hash = token_hash(user)
    token_hash[:authable] = user
    AuthorizationKey.create!(token_hash)
  end

  def self.send_otp(auth_key, user)
    if !auth_key.is_expired?
      otp = rand(10_000..99_999)
      if auth_key.update_attribute(:otp, otp) && user.update!(otp: otp)
        message = "Your One Time Password(OTP) for Shopoth is #{otp}"
        send_pin = SmsManagement::SendMessage.call(phone: user.phone, message: message)
        SmsLogJob.perform_later(SmsLog.sms_types[:otp],
                                send_pin.phone,
                                send_pin.message,
                                send_pin.gateway_response)
      end
    else
      token_hash = token_hash(user)
      otp = rand(10_000..99_999)
      token_hash[:otp] = otp
      if auth_key.update(token_hash) && user.update!(otp: otp)
        message = "Your One Time Password(OTP) for Shopoth is #{otp}"
        send_pin = SmsManagement::SendMessage.call(phone: user.phone, message: message)
        SmsLogJob.perform_later(SmsLog.sms_types[:otp],
                                send_pin.phone,
                                send_pin.message,
                                send_pin.gateway_response)
      end
    end
  end

  def self.token_hash(user)
    expiry = 3.month.from_now
    rand = SecureRandom.hex(10)
    hash = BCrypt::Password.create(rand)
    token = JWT.encode hash, Rails.application.secret_key_base
    { expiry: expiry, token: token }
  end
end
