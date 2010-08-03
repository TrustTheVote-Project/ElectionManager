# == Schema Information
# Schema version: 20100802153118
#
# Table name: ballot_style_templates
#
#  id                              :integer         not null, primary key
#  display_name                    :string(255)
#  default_voting_method           :integer
#  instruction_text                :text
#  created_at                      :datetime
#  updated_at                      :datetime
#  ballot_style                    :integer(255)
#  default_language                :integer
#  state_signature_image           :string(255)
#  medium_id                       :integer
#  instructions_image_file_name    :string(255)
#  instructions_image_content_type :string(255)
#  instructions_image_file_size    :string(255)
#

class BallotStyleTemplate < ActiveRecord::Base
  validates_presence_of [:display_name], :on => :create, :message => "can't be blank"
  
  has_attached_file :instructions_image,
    :styles => {
      :thumb=> "100x100#",
      :small  => "150x150>"
      # :medium => "300x300>",
      #       :large =>   "400x400>" 
      }
end
