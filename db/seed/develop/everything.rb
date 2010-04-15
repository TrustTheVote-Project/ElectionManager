COUNTIES = %w[Alameda ,Alpine , Amador , Butte , Calaveras , Colusa , 'Contra Costa' 
'Del Norte' , 'El Dorado', Fresno, Glenn, Humboldt, Imperial, 
Inyo, Kern, Kings, Lake, Lassen, 'Los Angeles', Madera, Marin 
Mariposa, Mendocino, Merced, Modoc, Mono, Monterey, Napa, Nevada
Orange, Placer, Plumas, Riverside, Sacramento, 'San Benito', 
'San Bernardino', 'San Diego', 'San Francisco',
'San Joaquin', 'San Luis Obispo',
'San Mateo', 'Santa Barbara', 'Santa Clara', 'Santa Cruz', Shasta, Sierra, Siskiyou, Solano 
Sonoma, Stanislaus, Sutter, Tehama, Trinity, Tulare, Tuolumne, Ventura, Yolo, Yuba ]

District.create(:district_type_id => 0, :display_name => "State of California")
District.create(:district_type_id => 1, :display_name => "Alameda County")
District.create(:district_type_id => 2, :display_name => "City of Aneheim")
District.create(:district_type_id => 3, :display_name => "Palo Alto School District")
District.create(:district_type_id => 4, :display_name => "Bear Valley Community Services District")
District.create(:district_type_id => 5, :display_name => "Felton Fire Protection District")
District.create(:district_type_id => 6, :display_name => "Eleventh Coast Guard District")
District.create(:district_type_id => 7, :display_name => "Moss Landing Harbor District")

# generates precincts, and associates them with districts
prs = Array[]
1.upto(20) { |i| prs.push Precinct.create(:display_name => "CA Precinct #{i}")}

puts "Creating district/precinct associations"
district = District.find(1)
prs.each { |precinct| district.precincts << precinct }
district = District.find(2)
prs[1..5].each { |precinct| district.precincts << precinct }
district = District.find(3)
prs[6..10].each { |precinct| district.precincts << precinct }
district = District.find(4)
prs[11..20].each { |precinct| district.precincts << precinct }

# creates a district set composed of all known districts
allDistricts = District.find(:all)
puts "Creating district set"
newSet = DistrictSet.create(:display_name => "Dummy District Set")
allDistricts.each do |district|
    newSet.districts << district
end
newSet.save()

# generate election
puts "Creating election"
election = Election.create(
  :display_name => "Dummy Election", 
  :ballot_style_template_id => 0,
  :start_date => Time.now + 10.days,
  :district_set_id => DistrictSet.find(:first).id)

# create contests, stick a few in each district

FIRST_NAMES = ["Aleks",'John', 'Pito','Gam','Ingrid','Arnold','Debra','John',]
LAST_NAMES = ['Totić', 'Shohet', 'Gorbatchov', 'Čurčil', 'Khan', 'Sebes', 'Simpson']

def randomCandidate
  "#{FIRST_NAMES.rand} #{LAST_NAMES.rand}"
end

CONTEST_1 = ["State", "Secretary", "Attorney", "City", "Appelate", "Liutenant"]
CONTEST_2 = ["Govenor", "Controller", "Treasurer", "Commisioner", "Mayor"]

def randomContest
  "#{CONTEST_1[rand(CONTEST_1.size)]} #{CONTEST_2[rand(CONTEST_2.size)]}"
end

ds = DistrictSet.find(election.district_set_id)
puts "Creating contests"
ds.districts.each do |district|
  1.upto(rand(10)) do |i|
    contest = Contest.create(
      :display_name => randomContest, 
      :open_seat_count => 1, 
      :voting_method_id => 0, 
      :district_id => district.id,
      :election_id => election.id)
    1.upto(rand(9)) do 
      contest.candidates << Candidate.create(
        :display_name => randomCandidate,
        :party_id => rand(Party.count))
    end
    contest.save
  end
end
