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
 
      @xml_body = @xml_root.get_elements('body')[0] 
      @xml_body.add_element('precinct') if @xml_body.get_elements('precinct').size == 1
      @xml_body.add_element('candidate') if @xml_body.get_elements('candidate').size == 1
      @xml_body.add_element('jurisdiction') if @xml_body.get_elements('jurisdiction').size == 1

      # Process districts/precincts
      districts = @xml_body.get_elements('district')         
      if districts != nil
        @xml_body.add_element('district') if districts.size == 1
        districts.each {|district| process_district district}
      end
      
      # Process elections/contests/candidates
      elections = @xml_body.get_elements('election')
      if elections != nil # size > 0
        @xml_body.add_element('election') if elections.size == 1
        elections.each {|election| process_election election}
      end
      
      xml_result = ''
      @rexml.write(xml_result)
      @election_data_hash = Hash.from_xml(xml_result)['ttv_object']
      @election_data_hash['body'] = pluralize_lists @election_data_hash['body']
      @election_data_hash['body'] = remove_empties @election_data_hash['body']
      @election_data_hash
    end

    # TODO: DRY
    def process_election election
      contests = election.get_elements('contest')
      if contests != nil # size > 0
        election.add_element('contest') if contests.size == 1
        contests.each {|contest| process_contest contest}
      end
    end
      
    def process_contest contest
      candidates = contest.get_elements('candidate')
      if candidates != nil # size > 0
        contest.add_element('candidate') if candidates.size == 1
      end
    end
    
    def process_district district
      precincts = district.get_elements('precinct')
      if precincts != nil # size > 0
        district.add_element('precinct') if precincts.size == 1
      end
    end
    
    def pluralize_lists hash
      pluralized = {}
      hash.each { |key, value|
        if(value.kind_of?(Array) && !pluralized[key] && !pluralized[key.chop])
          hash[key.to_s+"s"] = hash.delete(key)
          pluralized[key] = true
          
          # TODO: Process child elements
        end
      }
      hash
    end
    
    def remove_empties hash
      hash.each{|list, array|
        array.delete_if{|item| item.nil?}
        hash[list] = array
        # TODO: Process child elements
      }
      return hash
    end
  end
end