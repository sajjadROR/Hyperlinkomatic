class CreateBookMarks < ActiveRecord::Migration
  def change
    create_table :book_marks do |t|
      t.string :title
      t.string :link_path

      t.timestamps
    end
  end
end
