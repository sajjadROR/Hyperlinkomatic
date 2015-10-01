json.array!(@book_marks) do |book_mark|
  json.extract! book_mark, :id, :title, :url
  json.url book_mark_url(book_mark, format: :json)
end
