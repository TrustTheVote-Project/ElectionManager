# == Schema Information
# Schema version: 20100215144641
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
require 'abstract_ballot'
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
    
    def render_ballots(election, precinct, ballot_style_template)
      style = BallotStyle.find(ballot_style_template.ballot_style).ballot_style_code
      lang = Language.find(ballot_style_template.default_language).code
      instruction_text = ballot_style_template.instruction_text
      state_seal = ballot_style_template.state_graphic
      state_signature = ballot_style_template.state_signature_image
      pdfBallot = AbstractBallot.create(election, precinct, style, lang, instruction_text, state_seal, state_signature)
      title = precinct.display_name.gsub(/ /, "_").camelize + " Ballot.pdf"
      new_ballot = {:fileName => title, :pdfBallot => pdfBallot}
      return new_ballot
    end

end
