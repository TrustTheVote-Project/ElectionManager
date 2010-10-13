require 'machinist/active_record'
require 'sham'
require 'faker'


Sham.define do
  title { Faker::Lorem.words(5).join(' ') }
  #title { Faker::Lorem.sentence }
  body { Faker::Lorem.paragraphs(3).join("\n\n") }
  #body  { Faker::Lorem.paragraph }
  first_name(:unique => false) { Faker::Name.first_name }
  middle_initial(:unique => false) { ('a'..'z').to_a.rand.capitalize  } 
  last_name(:unique => false) { Faker::Name.last_name }
  name { Faker::Name.name }
  #name  {first_name << " " << last_name }
  email { |index| "#{index}" + Faker::Internet.email }
  address1(:unique => false) { Faker::Address.street_address }
  address2(:unique => false) { Faker::Address.secondary_address }
  city(:unique => false) { Faker::Address.city }
  postal_region(:unique => false) { Faker::Address.us_state_abbr }
  postal_code(:unique => false) { Faker::Address.zip_code }
  date_of_birth(:unique => false) { Date.today - (19 - rand(70)).year }
  # I don't like Faker phone numbers so I roll my own.
  phone_number(:unique => false) { ("%010d" % rand('9999999999')).insert(3, '-').insert(7, '-')  }
  
  login { Faker::Internet.user_name}
  description { Faker::Lorem.sentence }
  question { Faker::Lorem.sentence }

  role_name(:unique => false) { %w{ root standard public }.rand }
  
  jurisdiction_name(:unique => false) { %w{Northern MiddleSex Southern}.rand }

  display_name(:unique => false) { Faker::Lorem.words(1).first }
  ident { Faker::Lorem.words(1).first }
  
end

Sham.date do
  Date.civil((1905...2009).to_a.rand,
             (1..12).to_a.rand,
             (1..28).to_a.rand)
end

Sham.date_time { Sham.date.to_datetime }
# Can't use a limited set cuz Sham runs out of values. 
# Sham uses a deterministic set of values to generate values
#Sham.day { %w{monday tuesday wednesday thursday friday saturday sunday}.rand}
#Sham.day { Time::RFC2822_DAY_NAME.rand}
#Sham.week_type {["Fixed", "UDI"].rand }
#Sham.gender { g = %w{ m f M F}; g[rand(g.size)] }
#Sham.gender { g = %w{ m f M F}.rand }

# End of Shams

User.blueprint do
  email
  password { 'password' }
  password_confirmation { 'password'}
end

UserRole.blueprint do
  name { 'public' }
end

DistrictSet.blueprint do
  display_name { Sham.jurisdiction_name }
  secondary_name { "secondary name" + Sham.jurisdiction_name }
end

District.blueprint do
  display_name
#  district_set
end

Election.blueprint do
  display_name 
  district_set
  start_date  { Sham.date_time }
end

Contest.blueprint do
  display_name
  district
  election
  ident
end

Candidate.blueprint do
  # contest
  # party
  display_name
  ident
end

Question.blueprint do
  display_name
  requesting_district { District.make }
  election
  question
  ident
end

Precinct.blueprint do
  display_name
#  districts { District.make }
end

PrecinctSplit.blueprint do
  display_name
end

Language.blueprint do
end

JurisdictionMembership.blueprint do
  role { 'standard' }
end

JurisdictionMembership.blueprint(:admin) do
  role { 'admin' }
end

# NOTE: DistrictType, Party and VotingMethod are using the
# ConstantCache and loaded as seed data.

# TODO: remove these blueprints, they are loaded as seed data.
# Party::DEMOCRATIC, Party::REPUBLICAN, Party::INDEPENDENT

DistrictType.blueprint do
end

DistrictType.blueprint(:congressional) do
  title { "Congressional"}
end

Party.blueprint do
  display_name
  ident
end

Party.blueprint(:democrat) do
  display_name { 'Democrat'}
end

Party.blueprint(:republican) do
  display_name { 'Republican'}
end

Party.blueprint(:independent) do
  display_name { 'Independent'}
end

Party.blueprint(:independentgreen) do
  display_name { 'IndependentGreen'}
end

# NOTE: commented out blueprints because they are seed data

BallotStyle.blueprint do
  display_name
end

BallotStyle.blueprint(:office_block) do
  display_name { "Office Block"}
  ballot_style_code { "default"}
end

BallotStyle.blueprint(:party_column) do
   display_name { "Party Column"}
  # TODO: rename this to party_column ?
   ballot_style_code { "nh"}
 end

  Language.blueprint(:english) do
    display_name { "English"}
    code { "en" }
  end

#  VotingMethod.blueprint do

#  end
#  VotingMethod.blueprint(:winner_take_all) do
#    display_name { "Winner Take All"}
#  end

# VotingMethod.blueprint(:ranked) do
#   display_name { "Ranked"}
# end

BallotStyleTemplate.blueprint do
   display_name
   default_voting_method { VotingMethod::WINNER_TAKE_ALL }
   ballot_style { BallotStyle.make(:office_block).id}
  default_language { Language.make(:english).id }
#  instructions_image.urlimage_instructions { 'missing' }
  medium_id { 0}
  pdf_form { false}
 end
