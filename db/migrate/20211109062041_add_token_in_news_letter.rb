class AddTokenInNewsLetter < ActiveRecord::Migration[6.0]
  def change
    add_column :news_letters, :token, :string
  end
end
