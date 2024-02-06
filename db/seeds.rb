# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# order_last = Order.create
# byebug
# puts 'seeded'
#

# make staff roles

# StaffRole::ROLE_NAMES.each do |key, value|
#   staff_role = StaffRole.new(
#       name: value
#   )
#   staff_role.save
# end
#
# OrderStatus::order_types.each do |type_key, value|
#   order = OrderStatus.find_or_create_by(order_type: type_key)
#   status = "order_#{type_key}"
# order.update(system_order_status: status,
#              customer_order_status: status,
#              admin_order_status: status,
#              sales_representative_order_status: status,
#              partner_order_status: status)
# end

Configuration::SHIPPING_TYPE.each do |key, value|
  p "Configuration create for: 'shipping_type_#{key}'"
  Configuration.find_or_create_by(key: "shipping_type_#{key}").update(value: value)
end

Configuration::PICK_UP_CHARGE.each do |key, value|
  p "Configuration create for: 'pick_up_charge_#{key}'"
  Configuration.find_or_create_by(key: "pick_up_charge_#{key}").update(value: value)
end

# Creating ecom_app configuration
p 'App configuration create for: ecom_app'
Configuration.find_or_create_by(key: 'ecom_app').update(version_config: Configuration::ECOM_APP)

# Creating sr_app configuration
p 'App configuration create for: sr_app'
Configuration.find_or_create_by(key: 'sr_app').update(version_config: Configuration::SR_APP)

# Creating rider_app configuration
p 'App configuration create for: rider_app'
Configuration.find_or_create_by(key: 'rider_app').update(version_config: Configuration::RIDER_APP)

# Creating partner_app configuration
p 'App configuration create for: partner_app'
Configuration.find_or_create_by(key: 'partner_app').update(version_config: Configuration::PARTNER_APP)

# Creating min_cart_value configuration
p 'App configuration create for: min_cart_value'
Configuration.find_or_create_by(key: 'min_cart_value').update(value: 180)

# Creating emi_available_shipping configuration
p 'App configuration create for: emi_available_shipping options.'
Configuration.find_or_create_by(key: 'emi_available_shipping').update(version_config: Configuration::EMI_AVAILABLE_SHIPPING)

# Creating available_tenors configuration
p 'App configuration create for: available_tenors.'
Configuration.find_or_create_by(key: 'available_tenors').update(version_config: Configuration::AVAILABLE_TENURE)

# Creating minimum_price_to_avail_emi configuration
p 'App configuration create for: minimum_price_to_avail_emi.'
Configuration.find_or_create_by(key: 'minimum_price_to_avail_emi').update(value: Configuration::MINIMUM_PRICE_TO_AVAIL_EMI)
