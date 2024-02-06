class HelpTopicArticleBn < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :bn_title, :text, default: ''
    add_column :articles, :bn_body, :text, default: ''
    add_column :help_topics, :bn_title, :text, default: ''
  end
end
