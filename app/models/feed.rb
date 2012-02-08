class Feed < ActiveRecord::Base
  has_one   :country
  has_one   :category
  has_many  :keywords
end
