require 'yaml'
require 'rexml/document'

module TTV
  # Convert XML to the Election Data Hash format
  class XMLToEDH
    attr_reader :election_data_hash, :xml_root, :xml_body

    # <tt>xml::</tt> XML containing ElectionManager data
    def initialize(xml)
      @rexml =  REXML::Document.new xml
      @election_data_hash = {"audit_header" => {}, "ballot_info" => {}}
    end
    
    def convert
      @xml_root = @rexml.root
      raise "Invalid XML: <ttv_object> is not the root. " unless @xml_root.name == 'ttv_object'
 
      # With this method, we are creating a converter to bend the XML format
      # into an Election Data Hash. To use an unmodified Hash.from_xml function for this,
      # we currently use a few hack-y steps.
      # Step 1: Add "empty" elements for each object-type which has only one item included.
      #   This is done to nudge Hash.from_xml into treating these elements as members of an array.
      @xml_body = @xml_root.get_elements('body')[0] 
      @xml_body.add_element('contest') if @xml_body.get_elements('contest').size == 1
      @xml_body.add_element('candidate') if @xml_body.get_elements('candidate').size == 1
      @xml_body.add_element('jurisdiction') if @xml_body.get_elements('jurisdiction').size == 1
      @xml_body.add_element('split') if @xml_body.get_elements('split').size == 1

      #   Add empty elements for districts' jurisdiction references
      districts = @xml_body.get_elements('district')         
      if districts != nil
        @xml_body.add_element('district') if districts.size == 1
        districts.each {|district| add_empties_to_district district}
      end
      
      #   Add empty elements for elections' contest references
      elections = @xml_body.get_elements('election')
      if elections != nil
        @xml_body.add_element('election') if elections.size == 1
        elections.each {|election| add_empties_to_election election}
      end

      #   Add empty elements for precincts' district references
      precincts = @xml_body.get_elements('precinct')
      if precincts != nil
        @xml_body.add_element('precinct') if precincts.size == 1
        precincts.each {|precinct| add_empties_to_precinct precinct}
      end
      
      # Step 2: Convert to Hash
      xml_result = ''
      @rexml.write(xml_result)
      @election_data_hash = Hash.from_xml(xml_result)['ttv_object']
      
      # Step 3: Remove empty items we previously added to force arrays
      @election_data_hash['body'] = remove_empties @election_data_hash['body']
      
      # Step 4: Pluralize names of lists
      @election_data_hash['body'] = pluralize_lists @election_data_hash['body']
      
      return @election_data_hash
    end

    # TODO: DRY these add_empties_to functions
    
    # Adds empty element to election/contests to force conversion as array when necessary
    def add_empties_to_election election
      contests = election.get_elements('contest')
      if contests != nil # size > 0
        election.add_element('contest') if contests.size == 1
        contests.each {|contest| add_empties_to_contest contest}
      end
    end
    
    # Adds empty element to contest/candidates to force conversion as array when necessary
    def add_empties_to_contest contest
      candidates = contest.get_elements('candidate')
      if candidates != nil # size > 0
        contest.add_element('candidate') if candidates.size == 1
      end
    end
    
    # Adds empty element to district/jurisdictions to force conversion as array when necessary
    def add_empties_to_district district
      jurisdictions = district.get_elements('jurisdiction')
      if jurisdictions != nil # size > 0
        district.add_element('jurisdiction') if jurisdictions.size == 1
      end
    end

    # Adds empty element to precinct/districts to force conversion as array when necessary
    def add_empties_to_precinct precinct
      districts = precinct.get_elements('district')
      if districts != nil # size > 0
        precinct.add_element('district') if districts.size == 1
      end
    end
    
    # Recursively adds an 's' character to key for each array in a hash
    def pluralize_lists hash
      pluralized = {} # Note finished names, as renaming keys adds them to end of array
      hash.each { |key, value|
        if(value.kind_of?(Array) && !pluralized[key] && !pluralized[key.chop])
          hash[key.to_s+"s"] = hash.delete(key)
          pluralized[key] = true
          value.each{|item| pluralize_lists item if item}
        end
      }
      return hash
    end
    
    # Recursively removes empty items from arrays found in a hash
    def remove_empties hash
      hash.each{|key, value|
        if value.kind_of?(Array)
          value.delete_if{|item| item.nil?}
          value.each{|item| remove_empties item}
          hash[key] = value
        end
      }
      return hash
    end
  end
end