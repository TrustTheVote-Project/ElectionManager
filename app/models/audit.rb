class Audit < ActiveRecord::Base
  serialize :election_data_hash
  attr_accessible :display_name, :election_data_hash
  
  has_many :alerts
end
