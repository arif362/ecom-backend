class CreateFilteringOption < ActiveRecord::Migration[6.0]
  def change
    create_table :filtering_options do |t|
      t.integer :filtering_type, default: 0
      t.string :filtering_keys, array: true, default: []
      t.references :filterable, polymorphic: true, null: false
    end
  end
end
