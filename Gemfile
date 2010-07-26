source :gemcutter

gem 'rails', "2.3.5"
# failed on my Mac/OSX unless I use version 1.2.5. Which was already
# installed on my Mac. Probably should updgrade?
gem "sqlite3-ruby", "1.2.5", :require => "sqlite3"

gem "authlogic"
gem "prawn", '>= 0.7.2'
gem 'will_paginate', '~> 2.3.11'
gem 'tpitale-constant_cache', '>= 0.1.2', :require => 'constant_cache'
gem 'rubyzip', '>= 0.9.4', :require => 'zip/zip'
gem 'redgreen', '>=1.2.2'
gem 'searchlogic', '>=2.4.14'
gem 'cancan'

group :development do
end

group :test do
  gem 'shoulda', '=2.10.3',  :require => 'shoulda'
  gem 'machinist'
  gem 'faker'
  gem 'mocha'
  gem 'pdf-reader'
end

group 'cucumber' do
  gem 'machinist'
  gem 'faker'
  gem 'cucumber-rails',  '>=0.3.0',  :require => false
  gem 'database_cleaner',  '>=0.5.0', :require => false
  gem 'webrat',  '>=0.7.0', :require => false
  gem 'pickle', :require => false

end

group :production do
  
end
