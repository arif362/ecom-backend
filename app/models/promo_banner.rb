class PromoBanner < ApplicationRecord
  audited
  #############################
  ####### Association #########
  #############################
  has_many :banner_images, dependent: :destroy

  accepts_nested_attributes_for :banner_images, reject_if: :all_blank, allow_destroy: true

  #######################################
  ############## Validation #############
  #######################################
  validates :layout, numericality: { in: 1..3 }

  #######################################
  ########## Model callback #############
  #######################################
  after_save :all_images_present?, :only_one_banner_can_be_visible

  #######################################
  ############### Scope #################
  #######################################
  default_scope { order(id: :desc) }
  scope :visible, -> { where(is_visible: true) }

  #######################################
  ########### Public method #############
  #######################################
  def self.valid_images?(images)
    return false if images.empty?

    true
  end

  private

  #######################################
  ########### Private method ############
  #######################################
  def all_images_present?
    return if banner_images.app.size.to_i >= layout && banner_images.web.size.to_i >= layout

    fail 'Please give app and web images correctly.'
  end

  def only_one_banner_can_be_visible
    return unless PromoBanner.where(is_visible: true).size.to_i > 1

    fail 'Only one Promo banner can be visible at a time.'
  end
end
