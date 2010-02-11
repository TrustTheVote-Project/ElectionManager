# == Schema Information
# Schema version: 20100210222409
#
# Table name: elections
#
#  id              :integer         not null, primary key
#  display_name    :string(255)
#  district_set_id :integer
#  start_date      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

class Election < ActiveRecord::Base
    has_many :contests, :order => :display_name, :dependent => :destroy
    has_many :questions, :order => :display_name, :dependent => :destroy
    
    validates_presence_of :display_name
    belongs_to :district_set
    
    before_destroy :destroy_translations
    
    def to_s
      s = ""
      attributes.each do |key, value| 
        s += ("#{key}:#{value} ")
      end
      return s
    end
    
    def districts
      @districts = district_set.districts if (!@districts)
      @districts  
    end

    def validate 
       errors.add(:district_set_id , "is invalid") unless DistrictSet.exists?(district_set)
    end
    
    # really used for export. I'd use a different method, if I could force 'render :xml' to call it
    def to_xml( options = {}, &block )
      return TTV::ImportExport.export(self)
    end
    
    TRANSLATION_FOLDER = "#{RAILS_ROOT}/db/translations"
    
    def translation_path(lang)
      "#{TRANSLATION_FOLDER}/election-#{id}.#{lang}.yml"
    end
    
    def destroy_translations
      Dir.foreach TRANSLATION_FOLDER do |f|
        next unless f =~ /election-#{id}.*yml$/
        File.unlink("#{TRANSLATION_FOLDER}/#{f}")
      end
    end
    
end
