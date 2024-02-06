class AddIsDeletedToHelpTopics < ActiveRecord::Migration[6.0]
  def change
    add_column :help_topics, :is_deletable, :boolean, default: true
  end
end
