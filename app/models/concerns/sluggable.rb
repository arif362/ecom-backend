module Sluggable
  extend ActiveSupport::Concern

  included do
    after_commit :create_friendly_id_slug
    has_one :friendly_id_slug, dependent: :destroy, as: :sluggable, class_name: 'FriendlyIdSlug'

    validates :slug, presence: true
    validates_uniqueness_of :slug
  end

  private

  def create_friendly_id_slug
    FriendlyIdSlug.find_or_create_by(slug: slug, sluggable: self)
  end
end
