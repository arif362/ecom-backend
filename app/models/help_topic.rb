class HelpTopic < ApplicationRecord
  audited
  include Sluggable

  has_many :articles, dependent: :restrict_with_exception
  has_one :meta_datum, as: :metable, class_name: 'MetaDatum'

  # validations
  validates :title, presence: true
  validates :bn_title, presence: true
  validate :unique_title

  accepts_nested_attributes_for :meta_datum, reject_if: :all_blank, allow_destroy: true

  scope :published, -> { where public_visibility: true }

  # callback
  before_save :remove_white_space

  private

  def unique_title
    titles = if id.present?
               HelpTopic.where('LOWER(title) = ?', title.squish.downcase).where.not(id: id)
             else
               HelpTopic.where('LOWER(title) = ?', title.squish.downcase)
             end
    errors.add(:title, 'is already used') if titles.present?
  end

  def remove_white_space
    self.title = title.squish
  end
end
