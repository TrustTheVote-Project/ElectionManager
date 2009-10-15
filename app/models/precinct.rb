class Precinct < ActiveRecord::Base
  has_and_belongs_to_many :districts
  
  attr_accessor :importId # for xml import
    
end
