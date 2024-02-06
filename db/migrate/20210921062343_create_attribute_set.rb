class CreateAttributeSet < ActiveRecord::Migration[6.0]
  def change
    create_table :attribute_sets do |t|
      t.string :title
    end
  end
end
