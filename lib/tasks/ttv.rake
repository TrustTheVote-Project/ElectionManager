require 'active_record/fixtures'
require 'ttv/yaml_import'

Rake.application.remove_task 'db:test:prepare'

namespace :db do
  namespace :test do 
    task :prepare do |t|
      puts "Overriding db:test:prepare: Not deleting the test database"
    end
  end
end

namespace :ttv do
  desc "Heroku creation and initial push"
  task :heroku_create => :environment do
    #Rake::Task['ttv:production_reset'].invoke
    puts "check for previous heroku deployment"
    if sh %{grep "git@heroku.com" #{RAILS_ROOT}/.git/config}.include? "heroku"
      puts "previous heroku deployment detected. try rake ttv:heroku_update instead"
    else
      puts "create heroku instance with subdomain: #{ENV['subdomain']}"
      sh %{heroku create #{ENV['subdomain']}}
      if ENV['branch'].nil?
        puts "deploying branch develop to Heroku"
        sh %{git push heroku develop:refs/heads/master}
      else
        puts "deploying branch #{ENV['branch']} to Heroku"
        sh %{git push heroku #{ENV['branch']}:refs/heads/master}
      end
      puts "running production reset on Heroku"
      sh %{heroku rake ttv:production_reset}
    end
  end
  
  desc "Heroku update and reset"
  task :heroku_update => :environment do
    if ENV['branch'].nil?
      puts "deploying branch develop to Heroku"
      sh %{git push heroku develop:refs/heads/master}
    else
      puts "deploying branch #{ENV['branch']} to Heroku"
      sh %{git push heroku #{ENV['branch']}:refs/heads/master}
    end
    puts "running production reset on Heroku"
    sh %{heroku rake ttv:production_reset}  
  end
  
  
  desc "Full Reset of DB for development"
  task :dev_reset => :environment do
    ENV['RAILS_ENV'] = 'development'
    Rake::Task['db:reset'].invoke
    Rake::Task['db:seed'].invoke
    Rake::Task['ttv:seed'].invoke
    Rake::Task['ttv:develop'].invoke

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
    Rake::Task['ttv:production'].invoke
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
  task :develop => :environment do     
    load_fixtures 'seed/develop'
  end

  desc "Seed the database with production/ data."
  task :production => :environment do 
    import_yaml 'demo/**'
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
