class ConvertNullLinkUrlToEmptyString < ActiveRecord::Migration[6.0]
  def up
    Slide.find_each do |slide|
      slide.update link_url: '' if slide.link_url == 'null'
    end
  end

  def down; end
end
