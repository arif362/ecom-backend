class ChangeCategoryIdNullableInQuestionnaireTable < ActiveRecord::Migration[6.0]
  def change
    change_column_null(:questionnaires, :category_id, true)
  end
end
