# ####################################################
# # Create DistrictTypes
# ["(built-in default district type)", "State", "County", "Municipality", "School", "Water", "Fire", "Coastal", "Harbor", "US Congressional", "WARD", "CITYWI", "SMD"].each do |dt_name|
#   DistrictType.create!(:title => dt_name)
# end

# ####################################################
# # Create Districts
# d = District.new( :display_name => "CITY OF WASHINGTON WARD 6" )
# d.district_type = DistrictType.find_by_title("WARD")
# d.save!

# d = District.new( :display_name => "DISTRICT OF COLUMBIA" )
# d.district_type = DistrictType.find_by_title("CITYWI")
# d.save!

# d = District.new( :display_name => "1ST CONGRESSIONAL DIST-DEM")
# d.district_type = DistrictType.find_by_title("COND")
# d.save!

# d = District.new( :display_name => "SMD 01-ANC 6C")
# d.district_type = DistrictType.find_by_title("SMD")
# d.save!

# d = District.new( :display_name => "SMD 02-ANC 6C")
# d.district_type = DistrictType.find_by_title("SMD")
# d.save!

# d = District.new( :display_name => "SMD 03-ANC 6C")
# d.district_type = DistrictType.find_by_title("SMD")
# d.save!

# d = District.new( :display_name => "SMD 09-ANC 6C")
# d.district_type = DistrictType.find_by_title("SMD")
# d.save!

# d = District.new( :display_name => " CITY OF WASHINGTON WARD 2")
# d.district_type = DistrictType.find_by_title("CITYWI")
# d.save!

# d = District.new( :display_name => "SMD 01-ANC 2A")
# d.district_type = DistrictType.find_by_title("SMD")
# d.save!

# d = District.new( :display_name => "SMD 05-ANC 2A")
# d.district_type = DistrictType.find_by_title("SMD")
# d.save!

# d = District.new( :display_name => "SMD 06-ANC 2A")
# d.district_type = DistrictType.find_by_title("SMD")
# d.save!

####################################################
# Create Jurisdictions
#DistrictSet.create!( "secondary_name"=>"", "descriptive_text"=>"Nation Capitol",  :display_name =>"DC Jurisdiction"  )

####################################################
# Create Election
# e = Election.new(:display_name => "DC Election")
# e.default_voting_method_id = 1
# e.save!

# !!!!!!!!!!!!
# 1) create a Jurisdiction named "DC Jurisdiction".
# 1.1)  make this Jurisdiction the current jurisdiction.
# 2) import /Users/tom/TrustTheVote/converter/outputs/DC/medium.yml into
# this jurisdiction
# (This will create the district sets, districts, precinct splits)
# 3) Create and election named "DC Election"
# 4) Make this election's Jurisdiction the "DC Jurisdiciton"
# 5) Go into the console script/console
# 6) load 'db/dc_seeds.rb'
# (This will laod THIS file to populate the contests and candidates

####################################################
# Create Contests
def create_contest(pos, name, district_name)
  c = Contest.new(:position=> pos, :open_seat_count => 1, :display_name =>  name,
                  :ident => "ident-#{name}") 
  c.election = Election.find_by_display_name('DC Election')
  c.district = District.find_by_display_name(district_name)
  c.voting_method = VotingMethod::WINNER_TAKE_ALL
  c.save!
  c
end

pos = 0

# for district named "DISTRICT OF COLUMBIA"
['DELEGATE TO THE U.S. HOUSE OF REPRESENTATIVES', 'MAYOR OF THE DISTRICT OF COLUMBIA', "CHAIRMAN OF THE COUNCIL", "AT-LARGE MEMBER OF THE COUNCIL", "UNITED STATES REPRESENTATIVE"].each do |name|
  contest = create_contest(pos += 1, name, "DISTRICT OF COLUMBIA")
  ['Democratic', 'Republican', 'Green'].each do |cand_name|
    cand = Candidate.new(:display_name => "#{cand_name}_#{contest.id}")
    cand.ident = "ident-#{cand.display_name}" 
    cand.party = Party.find_by_display_name(cand_name)
    cand.contest = contest
    cand.save!
  end
end

pos = 0
# for district named "CITY OF WASHINGTON WARD 6"
["MEMBER OF THE COUNCIL WARD SIX", "MEMBER OF STATE BOARD OF EDUCATION WARD SIX", ].each do |name|
  contest = create_contest(pos += 1, name, "CITY OF WASHINGTON WARD 6")
  ['Democratic', 'Republican', 'Green'].each do |cand_name|
    cand = Candidate.new(:display_name => "#{cand_name}_#{contest.id}")
    cand.party = Party.find_by_display_name(cand_name)
    cand.contest = contest
    cand.save!
  end
end




