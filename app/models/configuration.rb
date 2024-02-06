class Configuration < ApplicationRecord
  serialize :version_config
  ###################################################################################
  ###### Need to add codes for new configurations on seed file ######################
  ###################################################################################

  # SHIPPING_TYPE prefix is shipping_type.
  SHIPPING_TYPE = {
    pick_up_point: 0,
    home_delivery: 100,
    express_delivery: 70,
  }.freeze

  # PICK_UP_CHARGE prefix is pick_up_charge.
  PICK_UP_CHARGE = {
    'from_home': 100,
    'to_partner': 0,
  }.freeze

  # Key for sr app will be sr_app.
  ECOM_APP = {
    'minimum_version': '1.0.9',
    'latest_version': '1.0.9',
    'is_android_published': false,
    'is_ios_published': false,
    'force_update': false,
  }.freeze

  # Key for sr app will be sr_app.
  SR_APP = {
    'minimum_version': '1.0.0',
    'latest_version': '2.0.0',
    'is_android_published': false,
    'is_ios_published': false,
    'force_update': false,
  }.freeze

  # Key for rider app will be rider_app.
  RIDER_APP = {
    'minimum_version': '1.0.0',
    'latest_version': '2.0.0',
    'is_android_published': false,
    'is_ios_published': false,
    'force_update': false,
  }.freeze

  # Key for partner app will be partner_app.
  PARTNER_APP = {
    'minimum_version': '1.0.0',
    'latest_version': '2.0.0',
    'is_android_published': false,
    'is_ios_published': false,
    'force_update': false,
  }.freeze

  # Key for emi_available_shipping options is EMI_AVAILABLE_SHIPPING.
  EMI_AVAILABLE_SHIPPING = { home_delivery: true, express_delivery: false, pick_up_point: false }.freeze

  # Key for minimum_price_to_avail_emi options is EMI_AVAILABLE_SHIPPING.
  MINIMUM_PRICE_TO_AVAIL_EMI = 0

  # Key for available_tenors is AVAILABLE_TENURE.
  AVAILABLE_TENURE = { tenure_1: 3, tenure_2: 6, tenure_3: 9, tenure_4: 12, tenure_5: 18, tenure_6: 24, tenure_7: 36 }.freeze

  after_save :update_configuration_cache

  def update_configuration_cache
    keys = %w(ecom_app sr_app rider_app partner_app)
    Rails.cache.delete(key.to_s)
    if keys.include?(key.to_s)
      Rails.cache.write(key.to_s, version_config)
    else
      Rails.cache.write(key.to_s, value)
    end
  end

  def self.order_shipping_charge(shipping_type)
    shipping_charge = Rails.cache.fetch("shipping_type_#{shipping_type}")
    return shipping_charge if shipping_charge.present?

    shipping_charge = Configuration.find_by(key: "shipping_type_#{shipping_type}").value
    Rails.cache.write("shipping_type_#{shipping_type}", shipping_charge)
    shipping_charge
  end

  def self.return_pick_up_charge(pick_up_type)
    pick_up_charge = Rails.cache.fetch("pick_up_charge_#{pick_up_type}")
    return pick_up_charge if pick_up_charge.present?

    pick_up_charge = Configuration.find_by(key: "pick_up_charge_#{pick_up_type}").value
    Rails.cache.write("pick_up_charge_#{pick_up_type}", pick_up_charge)
    pick_up_charge
  end

  def self.return_app_version_config(app_type)
    find_by(key: app_type)&.version_config
  end

  def self.min_cart_value
    find_by(key: 'min_cart_value').value.to_i
  end

  def self.shipping_charges
    keys = %w(shipping_type_pick_up_point shipping_type_home_delivery shipping_type_express_delivery)
    result = {}
    where(key: keys).each do |c|
      case c.key
      when 'shipping_type_pick_up_point'
        result[:pick_up_point] = c.value.to_i
      when 'shipping_type_home_delivery'
        result[:home_delivery] = c.value.to_i
      when 'shipping_type_express_delivery'
        result[:express_delivery] = c.value.to_i
      end
    end

    result
  end
end
