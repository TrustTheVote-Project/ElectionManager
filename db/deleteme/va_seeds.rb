# %w{ moe larry curly }.each do |name|
#   User.create(:email => "#{name}@example.com", :password => "password", :password_confirmation => "password")
# end
moe = User.find_or_create_by_email(:email => "moe@example.com", :password => "password", :password_confirmation => "password")
larry = User.find_or_create_by_email(:email => "larry@example.com", :password => "password", :password_confirmation => "password")
curly = User.find_or_create_by_email(:email => "curly@example.com", :password => "password", :password_confirmation => "password")

# create roles
%w{ public standard root}.each do |rolename|
  UserRole.find_or_create_by_name(:name => rolename)
end

moe.roles << UserRole.find_by_name('root')
larry.roles << UserRole.find_by_name('standard')
curly.roles << UserRole.find_by_name('public')

####################################################
# Create Jurisdictions

DistrictSet.create!({ "secondary_name"=>"", "descriptive_text"=>"Jurisdiction for Fairfax County, Virginia", "icon_file_size"=>18367, "icon_file_name"=>"fairfax_county_seal_n8882.gif", "icon_content_type"=>"image/gif", "display_name"=>"Fairfax County", "icon_updated_at"=> DateTime.now} )

DistrictSet.create!({"secondary_name"=>"State of Virginia", "descriptive_text"=>"Jurisdiction for the State of Virginia", "icon_file_size"=>50860, "icon_file_name"=>"200px-Seal_of_Virginia.png", "icon_content_type"=>"image/png", "display_name"=>"Commonwealth Of Virginia", "icon_updated_at"=>DateTime.now})

DistrictSet.create!({"secondary_name"=>"USA", "descriptive_text"=>"Jurisdiction for the United States of America",  "icon_file_size"=>25399, "icon_file_name"=>"US-GreatSeal-Obverse600px.jpg", "icon_content_type"=>"image/jpeg", "display_name"=>"United States of America", "icon_updated_at"=>DateTime.now})

####################################################
# Create DistrictTypes
["(built-in default district type)", "State", "County", "Municipality", "School", "Water", "Fire", "Coastal", "Harbor", "US Congressional"].each do |dt_name|
  DistrictType.create!(:title => dt_name)
end

####################################################
# Create Districts
d = District.new( "display_name"=> "Braddock Supervisor District" )
d.district_type = DistrictType.find_by_title("County")
d.save!

d = District.new("display_name"=> "Congressional District 11" )
d.district_type = DistrictType.find_by_title("US Congressional")
d.save!

d = District.new( "display_name"=> "Senate District 34" )
d.district_type = DistrictType.find_by_title("State")
d.save!

d = District.new( "display_name"=> "Virginia House of Delegates District 37" )
d.district_type = DistrictType.find_by_title("State")
d.save!

d = District.new( "display_name"=> "Commonwealth of Virginia" )
d.district_type = DistrictType.find_by_title("State")
d.save!

d = District.new( "display_name"=> "Fairfax County" )
d.district_type = DistrictType.find_by_title("County")
d.save!

ff_juris = DistrictSet.find_by_display_name("Fairfax County")
ff_juris.districts << District.find_by_display_name("Fairfax County")
ff_juris.districts << District.find_by_display_name("Braddock Supervisor District" )
ff_juris.save!

va_juris = DistrictSet.find_by_display_name("Commonwealth Of Virginia")
va_juris.districts << District.find_by_display_name("Commonwealth of Virginia" )
va_juris.districts << District.find_by_display_name("Virginia House of Delegates District 37" )
va_juris.districts << District.find_by_display_name("Senate District 34" )
va_juris.save!

us_juris =  DistrictSet.find_by_display_name("United States of America")
us_juris.districts << District.find_by_display_name("Congressional District 11" )
us_juris.save!

####################################################
# Create Precinct
precinct = Precinct.new("display_name"=>"Robinson Precinct 0123" )
District.all.each do |d|
  precinct.districts << d
end
precinct.save

####################################################
# Create VotingMethods
vm = VotingMethod.create!( "display_name"=>"Winner Take All")

####################################################
# Create Language
lang_en = Language.create!(:display_name => "English", :code => "en")

####################################################
# Create BallotStyle
BallotStyle.create!( "ballot_style_code"=>"nh", "display_name"=>"Party Column")
bs = BallotStyle.create!( "ballot_style_code"=>"default", "display_name"=>"Office Block") 

####################################################
# Create BallotStyleTemplate
bt = BallotStyleTemplate.create!( "medium_id"=>0, "instructions_image_file_name"=>nil, "instructions_image_file_size"=>nil, "state_signature_image"=>"", "display_name"=>"Office Block Ballot 1", "instructions_image_content_type"=>nil, "instruction_text"=>nil)
bt.ballot_style = bs.id
bt.default_language = lang_en.id
bt.default_voting_method = vm.id
bt.save!

####################################################
# Create Election
e = Election.new({"start_date"=> DateTime.now, "display_name"=>"2009 General and Special Election"} )
e.district_set = DistrictSet.find_by_display_name("Fairfax County")
e.default_voting_method_id = vm.id
e.ballot_style_template_id = bt.id
e.save!


####################################################
# Create Question
q = Question.new( "question"=>"Shall the Board of Supervisors of Fairfax County, Virginia, contract a debt, borrow money, and issue capital improvement bonds in the maximum aggregate principal amount of $232,580,000 for the purposes of providing funds, in addition to funds from school bonds previously authorized and any other available funds, to finance, including reimbursement to the County for temporary financing for, the costs of school improvements, including acquiring, building, expanding and renovating properties, including new sites, new buildings or additions, renovations and improvements to existing buildings, and furnishings and equipment, for the Fairfax County public school system?", "display_name"=>"School Bonds" )
q.requesting_district =  District.find_by_display_name("Fairfax County")
d =  District.find_by_display_name("Fairfax County")
q.election = e
q.save!

####################################################
# Create Contests
c = Contest.new("position"=>0,  "display_name"=>"Member House of Delegates 37th District", "open_seat_count"=>1)
c.election = e
c.district = District.find_by_display_name("Virginia House of Delegates District 37")
c.voting_method = vm
c.save!

c = Contest.new("position"=>0, "display_name"=> "Governor", "open_seat_count"=>1 )
c.election = e
c.district = District.find_by_display_name("Commonwealth of Virginia")
c.voting_method = vm
c.save!

c = Contest.new("position"=>0, "display_name"=>  "Lieutenant Governor", "open_seat_count"=>1 )
c.election = e
c.district = District.find_by_display_name("Commonwealth of Virginia")
c.voting_method = vm
c.save!

c = Contest.new("position"=>0, "display_name"=>"Attorney General", "open_seat_count"=>1 )
c.election = e
c.district = District.find_by_display_name("Commonwealth of Virginia")
c.voting_method = vm
c.save!

####################################################
# Create Parties
repub = Party.create!(:display_name =>"Republican")
dem = Party.create!(:display_name =>"Democrat")
ig = Party.create!(:display_name =>"Independent Green")
ind = Party.create!(:display_name =>"Independent")

####################################################
# Create Candidates
ca = Candidate.new("order"=>0, "display_name"=> 'Robert F. "Bob" McDonnell')
ca.party = repub
ca.contest = Contest.find_by_display_name("Governor")
ca.save!
ca = Candidate.new("order"=>0, "display_name"=> 'R. Creigh Deeds')
ca.party = dem
ca.contest = Contest.find_by_display_name("Governor")
ca.save!

ca = Candidate.new("order"=>0, "display_name"=> 'William T. "Bill" Bolling')
ca.party = repub
ca.contest = Contest.find_by_display_name("Lieutenant Governor")
ca.save!
ca = Candidate.new("order"=>0, "display_name"=> 'Jody M. Wagner')
ca.party = dem
ca.contest = Contest.find_by_display_name("Lieutenant Governor")
ca.save!

ca = Candidate.new("order"=>0, "display_name"=> 'Ken T. Cuccinelli')
ca.party = repub
ca.contest = Contest.find_by_display_name("Attorney General")
ca.save!
ca = Candidate.new("order"=>0, "display_name"=> 'Stephen C. Shannon')
ca.party = dem
ca.contest = Contest.find_by_display_name("Attorney General")
ca.save!

ca = Candidate.new("order"=>0, "display_name"=> 'David L. Bulova ')
ca.party = dem
ca.contest = Contest.find_by_display_name("Member House of Delegates 37th District")
ca.save!
ca = Candidate.new("order"=>0, "display_name"=> 'Anna M. Choi')
ca.party = ig
ca.contest = Contest.find_by_display_name("Member House of Delegates 37th District")
ca.save!
ca = Candidate.new("order"=>0, "display_name"=> 'Christopher F. DeCarlo')
ca.party = ind
ca.contest = Contest.find_by_display_name("Member House of Delegates 37th District")
ca.save!
