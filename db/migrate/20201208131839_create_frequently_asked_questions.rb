class CreateFrequentlyAskedQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :frequently_asked_questions do |t|
      t.text :question, null: false, index: true
      t.text :bn_question, null: false, index: true
      t.text :answer
      t.text :bn_answer
      t.integer :product_id, null: false, index: true

      t.timestamps
    end
  end
end
