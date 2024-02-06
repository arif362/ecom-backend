class RemoveMetaFromHelpTopic < ActiveRecord::Migration[6.0]
  def change
    remove_column :help_topics, :meta_title
    remove_column :help_topics, :bn_meta_title
    remove_column :help_topics, :meta_keyword
    remove_column :help_topics, :bn_meta_keyword
    remove_column :help_topics, :meta_description
    remove_column :help_topics, :bn_meta_description
  end
end
