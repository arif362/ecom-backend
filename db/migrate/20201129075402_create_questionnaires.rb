class CreateQuestionnaires < ActiveRecord::Migration[6.0]
  def change
    create_table :questionnaires do |t|
      t.text :question, null: false
      t.integer :category_id, null: false
      t.integer :questionnaire_type, null: false
      t.timestamps
    end
  end
end
