module ::TTV
  module BallotRule
    
    # NOTE: Don't forget to add this class to the ballot_rules.rb
    # initializer!!
    class DC < BallotRule::Base
      class << self
        def district_order
          @district_order ||= { "SMD" => 0, "COND" => 1,  "WARD" => 2,"CITYWI" => 3, "JOHN" => 4}
        end
      end

      # testing in console:
      # juris.jur_districts.sort(&bst.district_ordering).map(&:district_type).map(&:title)
      # where juris = jurisdiction and bst = ballot style template
      
      # district ordering shb:
      # 1) Federal (JOHN), 2) District of Columbia (CITYWI),
      # 3) Ward (WARD), 4) Congressional District (COND),
      # 5) SMD (SMD)
      # where: JOHN, CITYWI, WARD, COND AND SMD are the district types
      # in the import file
      def district_ordering
        return lambda do |d1, d2|
          # from the story, 5280202
          #%w{ FEDERAL COLUMBIA WARD CONGRESSIONAL SMD}.each_index do |i,ident|
          #  District.all.map{ |d| d.position = i; d.save! if d.ident =~ /ident/ }.compact 
          #end

          # where the district.district_type.titles
          # ["JOHN", "WARD", "CITYWI", "COND", "SMD"]
          # map to district.ident with substrings: 
          # ["FEDERAL", "WARD", "COLUMBIA", "CONGRESSIONAL", "SMD"]
          self.class.district_order[d2.district_type.title] <=> self.class.district_order[d1.district_type.title] 
        end
      end # end district_ordering
      
    end
  end
end
