class AddDescriptionInBookMark < ActiveRecord::Migration
  def change
    add_column :book_marks, :description, :text
  end
end
