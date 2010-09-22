module ::TTV
  module BallotRule
    
    class VA < BallotRule::Base

      # class singleton methods
      class << self

        # create the party ordering used in the candidate ordering
        # rule below
        def party_order
          # create it once for this class
          @party_order ||=  {Party::INDEPENDENT => 0, Party::LIBERTARIAN => 1, Party::INDEPENDENTGREEN => 2, Party::DEMOCRATIC => 3, Party::DEMOCRAT => 3, Party::REPUBLICAN => 4}
        end
        
      end # end class singleton methods
      
      def initialize(election=nil, precinct_split=nil)
        # TODO: may want to remove as thes are not currently used 
        @election = election
        @precinct_split = precinct_split
      end

      def candidate_ordering
        
        return lambda do |c1, c2|
          # puts "TGD: c1 = #{c1.display_name}"
          # puts "TGD: c1.party = #{c1.party.display_name}"
          # puts "TGD: c2 = #{c2.display_name}"
          # puts "TGD: c2.party = #{c2.party.display_name}"

          # puts "part_order = #{self.class.party_order.inspect}"
          if c1.party == c2.party
            c1.display_name <=> c2.display_name
          else
            # set the default to indy if candidate doesn't have a party
            c1.party = Party::INDEPENDENT unless c1.party
            c2.party = Party::INDEPENDENT unless c2.party
            # order candidates according to their party
            self.class.party_order[c2.party] <=> self.class.party_order[c1.party]
          end
        end

      end
      
    end
  end
end
