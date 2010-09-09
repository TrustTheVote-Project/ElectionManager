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
# Create DistrictTypes
["(built-in default district type)", "State", "County", "Municipality", "School", "Water", "Fire", "Coastal", "Harbor", "US Congressional", "WARD", "CITYWI", "SMD"].each do |dt_name|
  DistrictType.create!(:title => dt_name)
end

####################################################
# Create Districts
d = District.new( :display_name => "CITY OF WASHINGTON WARD 6" )
d.district_type = DistrictType.find_by_title("WARD")
d.save!

d = District.new( :display_name => "DISTRICT OF COLUMBIA" )
d.district_type = DistrictType.find_by_title("CITYWI")
d.save!

d = District.new( :display_name => "1ST CONGRESSIONAL DIST-DEM")
d.district_type = DistrictType.find_by_title("COND")
d.save!

d = District.new( :display_name => "SMD 01-ANC 6C")
d.district_type = DistrictType.find_by_title("SMD")
d.save!

d = District.new( :display_name => "SMD 02-ANC 6C")
d.district_type = DistrictType.find_by_title("SMD")
d.save!

d = District.new( :display_name => "SMD 03-ANC 6C")
d.district_type = DistrictType.find_by_title("SMD")
d.save!

d = District.new( :display_name => "SMD 09-ANC 6C")
d.district_type = DistrictType.find_by_title("SMD")
d.save!

d = District.new( :display_name => " CITY OF WASHINGTON WARD 2")
d.district_type = DistrictType.find_by_title("CITYWI")
d.save!

d = District.new( :display_name => "SMD 01-ANC 2A")
d.district_type = DistrictType.find_by_title("SMD")
d.save!

d = District.new( :display_name => "SMD 05-ANC 2A")
d.district_type = DistrictType.find_by_title("SMD")
d.save!

d = District.new( :display_name => "SMD 06-ANC 2A")
d.district_type = DistrictType.find_by_title("SMD")
d.save!

####################################################
# Create Jurisdictions
DistrictSet.create!( "secondary_name"=>"", "descriptive_text"=>"Nation Capitol",  display_name =>"District Of Columbia"  )

