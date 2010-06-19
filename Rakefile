# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'

Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end

require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'


begin
  require 'metric_fu'  
  MetricFu::Configuration.run do |config|
    config.rcov[:rcov_opts] << "-Itest"
  end
rescue MissingSourceFile  => e
  puts "You need to install the metric_fu gem"
  puts "rake gems:install RAILS_ENV=test"
  puts "#{e.inspect}"
  defined?(Rake) || throw(e)
end
