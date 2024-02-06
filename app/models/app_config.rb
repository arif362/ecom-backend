class AppConfig < ApplicationRecord
  belongs_to :registrable, polymorphic: true
end
