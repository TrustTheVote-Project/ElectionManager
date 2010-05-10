require 'rexml/document'

module TTV
  module ImportExport

    # imports an election from standard XML format
    class Import
      def initialize(source)
        @source = source
        @importIdDistrictMap = {}
        @precinctsMasterList = {}
        @election = nil
      end

      def importQuestions(xmlQuestions)
        questions = []
        xmlQuestions.each do |xmlQuestion|
          xmlText = xmlQuestion.get_elements('text')
          text = xmlText.size > 0 ? xmlText[0].text : ""
          text = text.rstrip.lstrip
          question = Question.create(:display_name => xmlQuestion.attributes['display_name'],
          :requesting_district_id => @importIdDistrictMap[xmlQuestion.attributes['district_idref']],
          :election_id => @election.id,
          :question => text );
          questions.push(question)
        end
        questions
      end

      def importCandidate(xmlCandidate)
        party_name = xmlCandidate.attributes['party']
  
        party = Party.find_by_display_name(party_name)
        if party.nil? 
          party = Party.new(:display_name => party_name)
        end
        
        #puts "XML Import: " + xmlCandidate.attributes['display_name'] + party.display_name
        new_candidate = Candidate.new(:display_name => xmlCandidate.attributes['display_name'],
                      :party_id => party.id)
        new_candidate.party = party
        new_candidate
      end

      def importContests(xmlContests)
        contests = []
        xmlContests.each do |xmlContest|
          contest = Contest.create(:display_name => xmlContest.attributes['display_name'],
          :order => xmlContest.attributes['order'],
          :open_seat_count => xmlContest.attributes['open_seat'],
          :voting_method_id => VotingMethod.xmlToId(xmlContest.attributes['voting_method'] || 'winner'),
          :district_id => @importIdDistrictMap[xmlContest.attributes['district_idref']],
          :election_id => @election.id )
          xmlContest.get_elements('candidates/candidate').each do | xmlCandidate |
            contest.candidates << importCandidate(xmlCandidate)
          end
          contests.push(contest)
        end
        contests
      end

      def createPrecinct(id, precinctsMasterList)
        newPrecinct = Precinct.new()
        newPrecinct.importId = id
        precinctsMasterList[id] = newPrecinct
      end

      def importDistrict(xmlDistrict, precinctsMasterList)
        district = District.new(:display_name => xmlDistrict.attributes['display_name'], 
                                :district_type_id => DistrictType.xmlToId(xmlDistrict.attributes['type'] ))
        importPrecincts = {}
        xmlDistrict.get_elements('precinct').each do |xmlPrecinct|
          id = xmlPrecinct.attributes['idref']
          if precinctsMasterList[id]
            importPrecincts[id] = precinctsMasterList[id]
          else
            importPrecincts[id] = createPrecinct(id, precinctsMasterList)
          end
        end
        district.importId = xmlDistrict.attributes['id']
        district.importPrecincts = importPrecincts
        district
      end

      # districts/precincts are REXML elements
      def importDistrictSet(xmlDistricts, xmlPrecincts)
        newSet = DistrictSet.new(:display_name => xmlDistricts.attributes['display_name'])
        newDistricts = []
        newPrecincts = {}
        xmlDistricts.get_elements('district').each do |xmlDistrict|
          newDistricts << importDistrict(xmlDistrict, newPrecincts)
        end
        xmlPrecincts.get_elements('precinct').each do |xmlPrecinct|
          id = xmlPrecinct.attributes['id']
          unless newPrecincts[id]
            newPrecincts[id] = Precinct.new()
            newPrecincts.importId = id
          end
          newPrecincts[id].display_name = xmlPrecinct.attributes['display_name']
        end
        # we have all new districts & precincts loaded, see if this district set is duplicate
        # duplicate? is a heuristic
        duplicates = DistrictSet.find_all_by_display_name(newSet.display_name)
        duplicates.each do |dup|
          if dup.districts.size == newDistricts.size && dup.precincts.size == newPrecincts.size
            newDistricts.each do |district|
              match = dup.districts.detect { |item| item.display_name == district.display_name}
              next unless match
              @importIdDistrictMap[district.importId] = match.id
            end
            return dup
          end
        end
        # duplicate not found, create the whole set
        newSet.save!
        newSet.reload
        newPrecincts.each_value { |precinct| precinct.save! }
        newDistricts.each do |district|
          district.save!
          district.importPrecincts.each_value { |precinct| district.precincts << precinct }
          newSet.districts << district
          @importIdDistrictMap[district.importId] = district.id
        end
        newSet
      end

      def import
          doc = REXML::Document.new @source
          xmlElection = doc.root
          raise "Invalid XML: <election> is not the root. " unless xmlElection.name == 'election' 
          ActiveRecord::Base.transaction do
            district_set = importDistrictSet(xmlElection.get_elements('districts')[0],
            xmlElection.get_elements('precincts')[0])
            @election = Election.create(:display_name => xmlElection.attributes['display_name'],
            :start_date => xmlElection.attributes['start_date'],
            :district_set_id => district_set.id)
            contests = importContests(xmlElection.get_elements('body/contest'))
            questions = importQuestions(xmlElection.get_elements('body/question'))
          end 
        @election
     end
     
     
      def import_batch
       xml_dir = Dir.new(@source)
       xml_dir.each do |xml_file|
         if xml_file[xml_file.length - 3..xml_file.length] == 'xml' && xml_file.class == 'File'
           file = File.new("#{@source}/#{xml_file}")
           doc = REXML::Document.new(file)
           xmlElection = doc.root
           raise "Invalid XML: <election> is not the root. " unless xmlElection.name == 'election'
           ActiveRecord::Base.transaction do
             district_set = importDistrictSet(xmlElection.get_elements('districts')[0],
             xmlElection.get_elements('precincts')[0])
             @election = Election.create(:display_name => xmlElection.attributes['display_name'],
             :start_date => xmlElection.attributes['start_date'],
             :district_set_id => district_set.id)
             contests = importContests(xmlElection.get_elements('body/contest'))
             questions = importQuestions(xmlElection.get_elements('body/question'))
           end 
         end
       end
       @election
    end
   
  end
    
  

    # exports the election as XML
    class Export
      def initialize(election)
        @election = election
        @xml = nil
        
        @ballot_config = @election.district_set == DistrictSet.find(0)
      end

      def exportDistrict(district)
        @xml.district :id => district.id, :display_name => district.display_name, :type => district.district_type.idToXml do 
          district.precincts.each do | precinct |
            @xml.precinct :idref => precinct.id
          end
        end
      end

      def exportPrecinct(precinct)
        @xml.precinct :id => precinct.id, :display_name => precinct.display_name        
      end

      def exportDistrictSet(district_set)
        @xml.districts :display_name => district_set.display_name do 
          district_set.districts.each do |district|
            exportDistrict(district)
          end
        end
        @xml.precincts do
          district_set.precincts.each do | precinct |
            exportPrecinct(precinct)
          end
        end
      end

      def exportCandidate(candidate)
        #puts "XML export: " + candidate.display_name + " " + candidate.party.display_name
        @xml.candidate :display_name => candidate.display_name,
          :party => candidate.party.display_name
      end

      def exportContest(contest)
        @xml.contest :display_name => contest.display_name, 
        :open_seat => contest.open_seat_count,
        :voting_method => contest.voting_method.idToXml,
        :district_idref => contest.district_id  do
          @xml.candidates do
            contest.candidates.each do |candidate|
              exportCandidate(candidate)
            end 
          end if contest.candidates.size != 0
        end
      end

      def exportQuestion(question)
        @xml.question :display_name => question.display_name, :district_idref => question.requesting_district_id do
          @xml.text do
            @xml << question.question
          end
        end
      end

      def export
        @xml = Builder::XmlMarkup.new( { :skip_types => true, :indent => 2 })
        @options = { :skip_types => true, :indent => 2, :skip_instruct => true, :builder => @xml}          
        @xml.instruct!
        @xml.election :display_name => @election.display_name, :start_date => @election.start_date do
          exportDistrictSet(@election.district_set)
          @xml.body do
            @election.contests.each do |contest|
              exportContest(contest)
            end
            @election.questions.each do |question|
              exportQuestion(question)
            end
          end
        end
        @xml.target!
      end
    end

    def ImportExport.export(election)
      exporter = TTV::ImportExport::Export.new(election)
      exporter.export
    end

    def ImportExport.import(source)
      begin
        importer = TTV::ImportExport::Import.new(source)
        importer.import();
      rescue Exception => ex
        raise ex
      end
    end

  end
end
