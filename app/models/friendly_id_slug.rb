class FriendlyIdSlug < ActiveRecord::Base
  belongs_to :sluggable, polymorphic: true

  validates :slug, presence: true, uniqueness: { case_sensitive: false }

end
