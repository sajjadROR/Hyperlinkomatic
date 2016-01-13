class BookMark < ActiveRecord::Base
  validates :link_path, presence: true, :format => {:with => URI.regexp}
  # default_scope { order('updated_at desc') }
  # validates_format_of :link_path, :with => /\A(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w\.-]*)*\/?\Z/i
end
