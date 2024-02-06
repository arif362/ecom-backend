class AddVersionConfigInConfigurationTable < ActiveRecord::Migration[6.0]
  def change
    add_column :configurations, :version_config, :text
  end
end
