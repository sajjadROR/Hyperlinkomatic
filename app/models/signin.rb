class Signin < ActiveRecord::Base
  validates :url, presence: true, :format => {:with => URI.regexp}
  default_scope { order('updated_at desc') }
end
