class CreateUserModifyReasons < ActiveRecord::Migration[6.0]
  def change
    create_table :user_modify_reasons do |t|
      t.string :title
      t.string :title_bn

      t.timestamps
    end
  end
end
