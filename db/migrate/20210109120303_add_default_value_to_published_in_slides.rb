class AddDefaultValueToPublishedInSlides < ActiveRecord::Migration[6.0]
  def change
    change_column_default :slides, :published, from: nil, to: true
  end
end
