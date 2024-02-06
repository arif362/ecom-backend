class CreateSliderConfig < ActiveRecord::Migration[6.0]
  def change
    create_table :slider_configs do |t|
      t.integer :interval
      t.timestamps
    end
  end
end
