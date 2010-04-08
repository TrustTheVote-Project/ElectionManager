class BallotStyleTemplate < ActiveRecord::Base
  validates_presence_of [:display_name,:instruction_text,:state_graphic], :on => :create, :message => "can't be blank"
end
