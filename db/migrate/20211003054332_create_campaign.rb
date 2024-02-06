class CreateCampaign < ActiveRecord::Migration[6.0]
  def change
    create_table :campaigns do |t|
      t.string :title
      t.string :title_bn
      t.string :page_url
      t.references :campaignable, polymorphic: true, null: false
    end
  end
end
