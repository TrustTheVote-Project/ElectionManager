# -*- coding: utf-8 -*-
# this file generated by script/generate pickle [paths] [email]
#
# Make sure that you are loading your factory of choice in your cucumber environment
#
# For machinist add: features/support/machinist.rb
#
#    require 'machinist/active_record' # or your chosen adaptor
#    require File.dirname(__FILE__) + '/../../spec/blueprints' # or wherever your blueprints are
#    Before { Sham.reset } # to reset Sham's seed between scenarios so each run has same random sequences
#
# For FactoryGirl add: features/support/factory_girl.rb
#
#    require 'factory_girl'
#    require File.dirname(__FILE__) + '/../../spec/factories' # or wherever your factories are
#
# You may also need to add gem dependencies on your factory of choice in <tt>config/environments/cucumber.rb</tt>

require 'pickle/world'
# Example of configuring pickle:
#

# Pickle.configure do |config|
#   %w{  factories adapters mappings predicates}.each do |ivar|
#     puts "Pickle config.#{ivar} = #{config.send(ivar.to_sym).inspect}}"
#   end
#   # default config.adapters = [:machinist, :factory_girl, :active_record]
#   # Will create models using first machinist, then factory_girl, finally active_record
#   # You can see this by examining config.factories
#   #  config.adapters = [:machinist]
  
#   #  config.map 'I', 'myself', 'me', 'my', :to => 'user: "me"'

# end
require 'pickle/path/world'
require 'pickle/email/world'
