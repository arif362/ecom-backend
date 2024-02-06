module Ecommerce
  module V1
    module Entities
      class Notification < Grape::Entity
        expose :id
        expose :details
        expose :bn_details
        expose :read
        expose :time_ago
        expose :user_notifiable_id
        expose :user_notifiable_type

        def time_ago
          created_ago = Time.now - object.created_at
          created_ago_in_days = (created_ago / 86_400).to_i
          created_ago_in_hours = (created_ago / 3600).to_i
          created_ago_in_minutes = (created_ago / 60).to_i

          if created_ago_in_days >= 1
            "#{created_ago_in_days} days ago"
          elsif created_ago_in_hours >= 1
            "#{created_ago_in_hours} hours ago"
          elsif created_ago_in_minutes >= 1
            "#{created_ago_in_minutes} minutes ago"
          else
            "#{created_ago.to_i} seconds ago"
          end
        end
      end
    end
  end
end
