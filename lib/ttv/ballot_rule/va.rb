module ::TTV
  module BallotRule
    
    class VA < BallotRule::Base
      
      class << self
        
        def party_order
          @party_order ||=  {Party::INDEPENDENT => 0, Party.find_by_display_name('IndependentGreen') => 1, Party::DEMOCRATIC => 2, Party::REPUBLICAN => 3}
        end
        
      end # end class methods
      
      def initialize(election=nil, precinct_split=nil)
        @election = election
        @precinct_split = precinct_split
      end

      def candidate_ordering
        #set the default to indy candidate doesn't have a party
        
        return lambda do |c1, c2|
          c1.party = Party::INDEPENDENT unless c1.party
          c2.party = Party::INDEPENDENT unless c2.party

          self.class.party_order[c1.party] <=> self.class.party_order[c2.party]
        end

      end
      
    end
  end
end
