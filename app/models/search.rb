class Search < ApplicationRecord
  belongs_to :warehouse, optional: true
  belongs_to :user, optional: true

  include PgSearch::Model
  pg_search_scope :search_related_keys, against: :search_key,
                                        using: {
                                          trigram: {
                                            threshold: 0.1,
                                          },
                                        }
end
