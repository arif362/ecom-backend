class AddSlugToHelpTopics < ActiveRecord::Migration[6.0]
  def change
    add_column :help_topics, :slug, :string
    add_index :help_topics, :slug, unique: true
  end
end
