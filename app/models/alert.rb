class Alert < ActiveRecord::Base
  serialize :options
  serialize :objects
  attr_accessible :display_name, :alert_type, :message, :objects, :choice, :default_option, :options
end
