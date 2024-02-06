class AddBoxableToBox < ActiveRecord::Migration[6.0]
  def change
    add_reference :boxes, :boxable, polymorphic: true, index: true
  end
end
