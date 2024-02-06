class AddTypeToSlides < ActiveRecord::Migration[6.0]
  def change
    add_column :slides, :img_type, :integer, default: 0
  end
end
