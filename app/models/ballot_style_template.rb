class BallotStyleTemplate < ActiveRecord::Base
  validates_presence_of [:display_name], :on => :create, :message => "can't be blank"
  
  has_attached_file :instructions_pdf,
    :styles => {
      :thumb=> "100x100#",
      :small  => "150x150>"
      # :medium => "300x300>",
      #       :large =>   "400x400>" 
      }
end
