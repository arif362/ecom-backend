class Article < ApplicationRecord
  include Sluggable
  audited

  belongs_to :help_topic
  has_one :meta_datum, as: :metable, class_name: 'MetaDatum'

  # Validation
  validates :title, presence: true
  validates :bn_title, presence: true
  validates :body, presence: true
  validates_uniqueness_of :title, scope: :help_topic_id, message: 'is already used under this help topic.'

  accepts_nested_attributes_for :meta_datum, reject_if: :all_blank, allow_destroy: true

  # Scope
  scope :published, -> { where public_visibility: true }

  def self.search_by_title(title = '')
    where(['LOWER(title) LIKE :key',
           { key: "%#{title.downcase}%" },])
  end

  # Callback
  before_save :remove_white_space

  private

  def slug_candidates
    [:title, [:title, :help_topic_id]]
  end

  def remove_white_space
    self.title = title.squish
  end
end
