require 'active_record/fixtures'

Rake.application.remove_task 'db:test:prepare'

namespace :db do
  namespace :test do 
    task :prepare do |t|
      puts "Overriding db:test:prepare: Not deleting the test database"
    end
  end
end

namespace :ttv do
  desc "Seed the database with always fixtures."
  task :seed => :environment do 
    load_fixtures "seed/once"
    load_fixtures "seed/always"
  end

  desc "Seed the database with develop/ fixtures."
  task :develop => :environment do     
    load_fixtures 'seed/develop'
  end
  
  private

  def load_fixtures(dir)
    Dir.glob(File.join(RAILS_ROOT, 'db', dir, '*.yml')).each do |fixture_file|
      puts "Loading #{fixture_file}"
      table_name = File.basename(fixture_file, '.yml')
      Fixtures.create_fixtures(File.join('db/', dir), table_name)
    end
    Dir.glob(File.join(RAILS_ROOT, 'db', dir, '*.rb')).each do |ruby_file|
      puts "Loading #{ruby_file}"
      require ruby_file
    end
  end  

  def table_empty?(table_name)
    quoted = connection.quote_table_name(table_name)
    connection.select_value("SELECT COUNT(*) FROM #{quoted}").to_i.zero?
  end

  def truncate_table(table_name)
    quoted = connection.quote_table_name(table_name)
    connection.execute("DELETE FROM #{quoted}")
  end

  def connection
    ActiveRecord::Base.connection
  end
end