class CreateAppConfig < ActiveRecord::Migration[6.0]
  def change
    create_table :app_configs do |t|
      t.string :fcm_token
      t.string :latest_app_version
      t.boolean :force_update, default: false
      t.references :registrable, polymorphic: true, null: false
    end
  end
end
