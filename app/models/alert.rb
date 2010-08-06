# == Schema Information
# Schema version: 20100802153118
#
# Table name: alerts
#
#  id             :integer         not null, primary key
#  display_name   :string(255)
#  alert_type     :string(255)
#  message        :string(255)
#  objects        :text
#  options        :text
#  choice         :text
#  default_option :text
#  created_at     :datetime
#  updated_at     :datetime
#  audit_id       :integer
#

class Alert < ActiveRecord::Base

  serialize :options
  serialize :objects
  attr_accessible :display_name, :alert_type, :message, :objects, :choice, :default_option, :options
end
