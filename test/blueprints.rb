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

  role_name(:unique => false) { %w{ root standard public }.rand }
  
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

