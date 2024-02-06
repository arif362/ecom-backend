class CreateMetaData < ActiveRecord::Migration[6.0]
  def change
    create_table :meta_data do |t|
      t.string :meta_title
      t.string :bn_meta_title
      t.text :meta_description
      t.text :bn_meta_description
      t.text :meta_keyword, array: true, default: []
      t.text :bn_meta_keyword, array: true, default: []
      t.integer :object_type

      t.timestamps
    end
  end
end
