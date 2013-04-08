class City < ActiveRecord::Base
  acts_as_cached
  #include Extensions::UUID
  attr_accessible :name
  has_many :city_propers
  has_many :source_cities
end
