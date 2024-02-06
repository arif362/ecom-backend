class BoxLineItem < ApplicationRecord
  audited
  belongs_to :box
  belongs_to :line_item

  def self.packable(line_items, box)
    box_line_items = line_items.map { |item| item[:line_item_id] }
    box_items = BoxLineItem.where(line_item_id: box_line_items, box_id: box.id)
    return { message: 'Items not found', packable: false } unless box_line_items.size == box_items.size

    { packable: true }
  end
end
