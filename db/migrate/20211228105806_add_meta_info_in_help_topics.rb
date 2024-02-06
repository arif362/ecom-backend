class AddMetaInfoInHelpTopics < ActiveRecord::Migration[6.0]
  def change
    add_column :help_topics, :meta_title, :string
    add_column :help_topics, :bn_meta_title, :string
    add_column :help_topics, :meta_description, :text
    add_column :help_topics, :bn_meta_description, :text
    add_column :help_topics, :meta_keyword, :text, array: true, default: []
    add_column :help_topics, :bn_meta_keyword, :text, array: true, default: []
  end
end
