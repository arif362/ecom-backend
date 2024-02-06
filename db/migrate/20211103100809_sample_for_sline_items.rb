class SampleForSlineItems < ActiveRecord::Migration[6.0]
  def change
    add_column :shopoth_line_items, :sample_for, :integer, null: true
  end
end
