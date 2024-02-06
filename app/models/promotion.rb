class Promotion < ApplicationRecord
  audited
  belongs_to :warehouse, optional: true
  belongs_to :staff, optional: true
  has_many :promotion_variants, dependent: :destroy
  has_many :variants, through: :promotion_variants
  # has_many :category_promotions, dependent: :destroy
  has_many :promotion_rules, autosave: true, dependent: :destroy
  has_many :brand_promotions, dependent: :destroy
  has_many :brands, through: :brand_promotions
  has_many :shopoth_line_items, dependent: :nullify
  has_many :carts, dependent: :nullify
  has_many :customer_orders, dependent: :nullify
  has_many :coupons, dependent: :destroy
  has_many :cart_promotions
  has_many :customer_order_promotions
  # TODO: Need to add polymorphic association between notifications and promotions
  # has_many :notifications, as: :user_notifiable

  validates :title, :from_date, :to_date, presence: true
  validates :promotion_variants, presence: true, if: :flash_sale?

  ###############################
  ######## Model Callback #######
  ###############################
  validate :restrict_negative_rules

  default_scope { order('id DESC') }
  scope :active, -> { where(is_active: true) }
  scope :unexpired, -> { where('from_date <= :today AND to_date >= :today', today: Date.today) }
  scope :shipping_charge, -> { where(rule: 'shipping_charge') }

  enum promotion_category: %w(
    sku
    ra_discount
    category
    cash_back
    by_payment
    outlet_discount
    by_customer
    customer_coupon
    minimum_cart_value
    flash_sale
    brand
    first_reg_coupon
  )

  def self.settings
    PromotionEngine::Configuration.settings
  end

  def running?
    return false unless is_active

    start_date = Time.zone.parse(from_date.to_s) + Time.zone.parse(start_time).seconds_since_midnight.seconds
    end_date = Time.zone.parse(to_date.to_s) + Time.zone.parse(end_time).seconds_since_midnight.seconds
    Time.now.in_time_zone('Asia/Dhaka').between?(start_date, end_date)
  end

  def self.flash_unexpired
    where("CONCAT(from_date, ' ', start_time)::timestamp AT TIME ZONE 'Asia/Dhaka' <= :today
 AND CONCAT(to_date, ' ', end_time)::timestamp AT TIME ZONE 'Asia/Dhaka' >= :today",
          today: Time.now.in_time_zone('Asia/Dhaka'))
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def create_rules(param)
    pv = []
    pr = []
    bp = []
    promotion_param = param[:promotion]
    rule_param = param[:promotion][:promotion_rule]
    category = promotion_param[:promotion_category]

    ActiveRecord::Base.transaction do
      self.rule = rule_param[:rule]
      # rubocop:disable Style/CaseLikeIf
      if rule_param[:rule] == 'buy_x_get_y'
        pv = create_promotion_variants(rule_param)

        rules_from_pv = []
        rules_from_pv << rule_param[:fields].detect { |x| x[:name] == 'x_qty' }
        rules_from_pv << rule_param[:fields].detect { |x| x[:name] == 'y_qty' }

        rules_from_pv.each do |r_pv|
          pr << { name: r_pv[:name], value: r_pv[:value][0] }
        end

      elsif category == 'sku'
        pv = create_promotion_variants(rule_param)
        pr = store_other_rules(rule_param)
      elsif category == 'brand'
        bp = fetch_brand_ids(rule_param)
        pr = store_other_rules(rule_param)
      else
        rule_param[:fields].each do |f|
          pr << { name: f[:name], value: f[:value][0] }
        end
      end
      promotion_variants.build(pv)
      brand_promotions.build(bp)
      promotion_rules.build(pr)
      save!
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def update_rules(param)
    pv = []
    bp = []
    promotion_param = param[:promotion]
    rule_param = param[:promotion][:promotion_rule]
    category = promotion_param[:promotion_category]

    ActiveRecord::Base.transaction do
      if rule_param[:rule] == 'buy_x_get_y'
        promotion_variants.delete_all
        reload
        pv = create_promotion_variants(rule_param)
        rules_pv = []
        rules_pv << rule_param[:fields].detect { |x| x[:name] == 'x_qty' }
        rules_pv << rule_param[:fields].detect { |x| x[:name] == 'y_qty' }

        rules_pv.each do |r_pv|
          promotion_rules.find(r_pv[:id]).update_attribute(:value, r_pv[:value][0])
        end
      elsif category == 'sku'
        promotion_variants.delete_all
        reload
        pv = create_promotion_variants(rule_param)
        update_other_rules(rule_param)
      elsif category == 'brand'
        Promotion.transaction do
          brand_promotions.delete_all
          reload
          bp = fetch_brand_ids(rule_param)
          update_other_rules(rule_param)
        end
      else
        rule_param[:fields].each do |f|
          promo_rule = promotion_rules.find(f[:id])
          next if promo_rule.name == 'coupons'

          promo_rule.update_attribute(:value, f[:value][0])
        end
      end
      promotion_variants.build(pv)
      brand_promotions.build(bp)

      self.title = promotion_param[:title]
      self.from_date = promotion_param[:from_date].to_datetime.utc
      self.to_date = promotion_param[:to_date].to_datetime.utc
      self.is_active = promotion_param[:is_active]
      self.is_time_bound = promotion_param[:is_time_bound]
      self.start_time = promotion_param[:start_time]
      self.end_time = promotion_param[:end_time]
      self.days = promotion_param[:days]

      save!
    end
  end

  def value_for(name)
    promotion_rules.find_by(name: name).value
  end

  private

  def create_promotion_variants(param)
    pv = []

    param[:fields].each do |f|
      # rubocop:disable Style/CaseLikeIf
      if f[:name] == 'x_skus'
        f[:value].each do |v|
          pv << { variant_id: v, state: 'buy' }
        end
      elsif f[:name] == 'y_skus'
        f[:value].each do |v|
          pv << { variant_id: v, state: 'get' }
        end
      elsif f[:name] == 'variant_skus'
        f[:value].each do |v|
          pv << { variant_id: v, state: 'sku_promo' }
        end
      end
    end
    pv
  end

  def fetch_brand_ids(param)
    brand_ids = param[:fields].select { |xs| xs[:name] == 'brand_names' }.pluck(:value).flatten
    brand_ids.map do |id|
      { brand_id: id, state: 'brand_promo' }
    end
  end

  def store_other_rules(param)
    pr = []
    param[:fields].each do |f|
      next if f[:name] == 'variant_skus' || f[:name] == 'brand_names'

      pr << { name: f[:name], value: f[:value][0] }
    end
    pr
  end

  def update_other_rules(param)
    param[:fields].each do |f|
      promo_rule = promotion_rules.find(f[:id])
      next if promo_rule.name == 'coupons' || f[:name] == 'variant_skus' || f[:name] == 'brand_names'

      promo_rule.update_attribute(:value, f[:value][0])
    rescue StandardError => error
      puts '--- Exception | Promotion.rb'
      puts "Exception occurs: #{error.message}"
    end
  end

  def restrict_negative_rules
    return unless promotion_rules.pluck(:value).any?(&:negative?)

    errors.add(:base, "Promotion rules value can't be negative.")
  end
end
