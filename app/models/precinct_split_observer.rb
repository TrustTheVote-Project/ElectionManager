 class PrecinctSplitObserver < ActiveRecord::Observer
   def after_destroy(precinct_split)
     Ballot.destroy_all(:precinct_split_id => precinct_split.id)
   end
 end
