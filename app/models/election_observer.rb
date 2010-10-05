 class ElectionObserver < ActiveRecord::Observer
   def after_destroy(election)
     Ballot.destroy_all(:election_id => election.id)
   end
 end
