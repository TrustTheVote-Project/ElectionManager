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

