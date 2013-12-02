class Ingredient < ActiveRecord::Base
  replicate "test"

  belongs_to :recipe
end
