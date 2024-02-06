class Brand < ApplicationRecord
  audited
  include Sluggable
  include ImageVersions
  include Rails.application.routes.url_helpers

  scope :publicly_visible, -> { where(public_visibility: true) }
  default_scope { where(is_deleted: false) }

  belongs_to :staff, optional: true
  has_many :products
  has_many :brand_followings
  has_many :campaigns, as: :campaignable
  has_many :filtering_options, as: :filterable
  has_many :brand_promotions, dependent: :nullify
  has_many :promotions, through: :brand_promotions
  has_one :meta_datum, as: :metable, class_name: 'MetaDatum'
  has_many :promo_coupon_rules, as: :ruleable, class_name: 'PromoCouponRule', dependent: :destroy
  has_many :promo_coupons, through: :promo_coupon_rules

  has_one_attached :logo
  has_many_attached :banners
  has_one_attached :branding_image

  validates :name, :bn_name, presence: true, uniqueness: true
  validates :logo, attached: true, content_type: %w(image/jpg image/jpeg image/png image/webp), size: { less_than: 3.megabytes }, on: :save
  validates :banners, blob: { content_type: %w(image/jpg image/jpeg image/png image/webp), size_range: 1..3.megabytes }
  validates :unique_id, uniqueness: true

  accepts_nested_attributes_for :campaigns, reject_if: :all_blank, allow_destroy: true, update_only: true
  accepts_nested_attributes_for :filtering_options, reject_if: :all_blank, allow_destroy: true, update_only: true
  accepts_nested_attributes_for :meta_datum, reject_if: :all_blank, allow_destroy: true

  before_create :assign_unique_id, :call_3ps_apis
  before_update :call_3ps_update_api

  enum branding_layout: { full: 0, box: 1 }
  enum branding_promotion_with: { image: 0, video: 1 }

  scope :filter_by, ->(name = '') {
    where('LOWER(name) LIKE ?', "%#{name.downcase}%").limit(25)
  }

  def logo_file=(file)
    return if file.blank?

    logo.attach(
      io: file[:tempfile],
      filename: file[:filename],
      content_type: file[:type],
    )
  end

  def banners_file=(file_arr)
    return if file_arr.blank?

    img_arr = []
    file_arr.each do |file|
      file_hash = {
        io: file[:tempfile],
        filename: file[:filename],
        content_type: file[:type],
      }
      img_arr << file_hash
    end
    self.banners = img_arr
  end

  def branding_image_file=(file)
    branding_image.attach(
      io: file[:tempfile],
      filename: file[:filename],
      content_type: file[:type],
    )
  end

  def self.get_img_url(image_variation, obj)
    Rails.application.routes.url_helpers.rails_representation_url(obj.variant(Brand.sizes[image_variation.to_sym]).processed, only_path: true)
  end

  def brand_name_downcase
    name.downcase
  end

  def assign_unique_id
    self.unique_id = SecureRandom.uuid
  end

  def call_3ps_apis
    response = Thanos::Brand.create(self)
    return unless response[:error].present?

    e = errors.add(:base, (response[:error_descrip]).to_s)
    fail StandardError, e.to_s
  end

  def call_3ps_update_api
    response = Thanos::Brand.update(self)
    return unless response[:error].present?

    e = errors.add(:base, (response[:error_descrip]).to_s)
    fail StandardError, e.to_s
  end
end
