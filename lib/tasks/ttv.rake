require 'active_record/fixtures'
require 'ttv/yaml_import'

# Since we add a bunch of test data using ttv:rest_reset, the usual test:prepare would erase that
# and cause tests to fail. I need to find out what the 'right way' to build test data is that 
# would not require the cancelling of the default db:test_prepare. But until then...
Rake.application.remove_task 'db:test:prepare'

namespace :db do
  namespace :test do 
    task :prepare do |t|
      puts "Overriding db:test:prepare: Not deleting the test database"
    end
  end
end

namespace :ttv do
  desc "Full Reset of DB for development"
  task :dev_reset => :environment do
    ENV['RAILS_ENV'] = 'development'
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:reset'].invoke
    Rake::Task['db:seed'].invoke
    Rake::Task['ttv:seed'].invoke
    Rake::Task['ttv:develop_seed'].invoke

 end
  
  desc "Full Reset of DB for test"
  task :test_reset => :environment do
    RAILS_ENV = 'test'
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
    Rake::Task['db:schema:load'].execute
    
    Rake::Task['ttv:seed'].execute
  end

  desc "Full Reset of DB for production"
  task :production_reset => :environment  do
    Rake::Task['db:reset'].invoke
    Rake::Task['db:seed'].invoke
    Rake::Task['ttv:seed'].invoke
#    Rake::Task['ttv:production_seed'].invoke
  end
  
  desc "Full Reset of DB for test and development"
  task :full_reset => ['ttv:dev_reset', 'ttv:test_reset'] do
  end
end

namespace :ttv do
  desc "Seed the database with always fixtures."
  task :seed => :environment do 
    load_fixtures "seed/once"
    load_fixtures "seed/always"
  end

  desc "Seed the database with develop/ fixtures."
  task :develop_seed => :environment do     
    load_fixtures 'seed/develop'
  end

  desc "Seed the database with production/ data."
  task :production_seed => :environment do 
#    import_yaml 'demo/**'
  end
  
  private

  def import_yaml(dir)
    Dir.glob(File.join(RAILS_ROOT, dir, '*.yml')).each do |fixture_file|
      puts "Loading #{fixture_file}"
      
      import_file = File.new(fixture_file)
      importer = TTV::YAMLImport.new(import_file)
      importer.import
    end
    Dir.glob(File.join(RAILS_ROOT, dir, '*.xml')).each do |fixture_file|
      puts "Loading #{fixture_file}"
      
      file = File.new(fixture_file)
      imported = TTV::ImportExport.import(file) 
    end
  end

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
