class Recipe < ActiveRecord::Base
  replicate "test"

  has_many :ingredients
end
