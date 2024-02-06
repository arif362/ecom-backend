class CreateHelpTopics < ActiveRecord::Migration[6.0]
  def change
    create_table :help_topics do |t|
      t.string :title
      t.boolean :public_visibility, default: true
      t.timestamps
    end
  end
end
