class Election < ActiveRecord::Base
    has_many :contests, :order => :display_name, :dependent => :destroy
    has_many :questions, :order => :display_name, :dependent => :destroy
    
    validates_presence_of :display_name
    belongs_to :district_set
    
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
       errors.add(:district_set_id , "is invalid") unless DistrictSet.exists?(district_set_id)
    end
    
    # really used for export. I'd use a different method, if I could force 'render :xml' to call it
    def to_xml( options = {}, &block )
      return TTV::ImportExport.export(self)
    end
    
end
