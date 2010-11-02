# == Schema Information
# Schema version: 20100813053101
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
  
  serialize :page
  #  serialize :frame, Hash
  serialize :frame
  serialize :contents
  serialize :ballot_layout
  
  attr_accessor :frame, :page, :contents, :ballot_layout
  
  validates_presence_of [:display_name], :on => :create, :message => "can't be blank"
  
  has_attached_file :instructions_image,
  :styles => {
    :thumb=> "100x100#",
    :small  => "150x150>"
    # :medium => "300x300>",
    #       :large =>   "400x400>" 
  }
  
   def after_initialize
     @page = { }; @frame = { }; @contents = {}; @ballot_layout = {} 
     
#      # default page params
#      @page ||= { 'size' =>  "LETTER",
#        'layout' => :portrait,
#        'background' => '000000',
#        'margin' => { 'top' => 0, 'right' => 0, 'bottom' => 0, 'left' => 0}
#      }
#      default_frame
#      default_ballot_layout
#      default_contents
#      puts "TGD: page = #{@page.inspect}"
#      puts "TGD: frame = #{@frame.inspect}"
#      puts "TGD: contents = #{@contents.inspect}"
#      puts "TGD: ballot_layout = #{@ballot_layout.inspect}"
   end
  
  def default_frame

    self.frame ||= {
      'margin' => {'top' => 0, 'right' => 0, 'bottom' => 0, 'left' => 0},
      'border' =>  {'width' => 0, 'color' => '000000', 'style' => :solid},
      'content' =>{
        'top' => { 'width' => 50, 'text' => "Sample Ballot", 'rotate' => 0},
        'right' => { 'width' => 47,'text' => " tom D was here", 'rotate' => 90},
        'bottom' => { 'width' => 50,'text' => "Sample Ballot", 'rotate' => 0 },
        'left' => { 'width' => 67,'text' => "    132301113              Sample Ballot", 'rotate' => 90 }
      }}
  end
  
  def default_ballot_layout
    self.ballot_layout ||= { 'create_A_headers' => true} 
  end
  
  def default_contents
    
    self.contents ||= {
      'border' => {'width' => 1, 'color' => '000000', 'style' => :dashed},
      'header' =>{
        'width' => 498,
        'height' => 154,
        'margin' => {'top' => 0, 'right' => 0, 'bottom' => 0, 'left' => 0},
        'border' => {'width' => 0, 'color' => '000000', 'style' => :solid},
        'text' => "Header Text", # this will be Rich Text in Prawn 1.0
        'background_color' => '000000',
      },

      'body' =>{
        'width' => 1.0, # % width of ballot contents box
        'height' => 1.0, # % height of ballot contents box
        'margin' => {'top' => 0, 'right' => 0, 'bottom' => 0, 'left' => 0},
        'border' => {'width' => 0, 'color' => '000000', 'style' => :solid},
        'text' => "Body Text", # this will be Rich Text in Prawn 1.0
        'background_color' => '000000',
      },
      'footer' =>{
        'width' => 1.0, # % width of ballot contents box
        'height' => 0.0, # % height of ballot contents box
        'margin' => {'top' => 0, 'right' => 0, 'bottom' => 0, 'left' => 0},
        'border' => {'width' => 0, 'color' => 'FF0000', 'style' => :solid},
        'text' => "Footer Text", # this will be Rich Text in Prawn 1.0
        'background_color' => '#00FF00'
      }
    }
  end
  
  # given a hash of styles update the page, frame and contents attributes/hashes.
  def update_styles(styles_hash)
    @page.merge!(styles_hash['page']) if styles_hash['page']
    @frame.merge!(styles_hash['frame']) if styles_hash['frame']
    @contents.merge!(styles_hash['contents']) if styles_hash['contents']
    @ballot_layout.merge!(styles_hash['ballot_layout']) if styles_hash['ballot_layout']
    save!
  end
  
  def reload_style
    logger.debug "TGD: reloading ballot style file #{ballot_style_file.inspect}"
    load_style(self.ballot_style_file) if self.ballot_style_file
  end
  
  def load_style(filename)
    self.ballot_style_file = filename
    
    style_hash = {}
    
    File.open(filename) do |yaml_file|
      #logger.debug "TGD: opening yamle file #{filename}"
      style_hash = YAML.load(yaml_file)
    end
    
    # puts  "TGD: style_hash = #{style_hash.inspect}"
    
#     logger.debug "="*30    
#     logger.debug "\nTGD: style_hash[:frame][:margin] = #{style_hash[:frame][:margin].inspect}"
#     logger.debug "\nTGD: style_hash[:frame][:content][:top] = #{style_hash[:frame][:content][:top].inspect}"
#     logger.debug "\nTGD: style_hash[:frame][:content][:right] = #{style_hash[:frame][:content][:right].inspect}"
#     logger.debug "\nTGD: style_hash[:frame][:content][:bottom] = #{style_hash[:frame][:content][:bottom].inspect}"
#     logger.debug "\nTGD: style_hash[:frame][:content][:left] = #{style_hash[:frame][:content][:left].inspect}"
#     logger.debug "\nTGD: style_hash[:frame][:border] = #{style_hash[:frame][:border].inspect}"
    
#     logger.debug "="*30    
#     logger.debug "\nTGD: style_hash[:contents][:body] = #{style_hash[:contents][:body].inspect}"
#     logger.debug "\nTGD: style_hash[:contents][:footer] = #{style_hash[:contents][:footer].inspect}"
#     logger.debug "\nTGD: style_hash[:contents][:header] = #{style_hash[:contents][:header].inspect}"
#     logger.debug "\nTGD: style_hash[:contents][:border] = #{style_hash[:contents][:border].inspect}"
    
    update_styles(style_hash)
  end

  
  def to_yaml
    { :page => page, :frame => frame, :contents => contents, :ballot_layout => ballot_layout}.to_yaml
  end

  def create_A_ballot_headers?
    ballot_layout && ballot_layout['create_A_headers']
  end

  # get the ballot rule given this template's ballot rule class name
  # e.g. if ballot_rule_classname is "VA" then get TTV::BallotRule::VA
  # class
  def ballot_rule_class
    ::TTV::BallotRule::Base.find_subclass(ballot_rule_classname)
  end
  
  # get and instance of the ballot rule indicated by the
  # ballot_rule_classname attribute
  def ballot_rule
    ballot_rule_class.new
  end

  # Supplies the sorting algorithm for districts
  # districts.sort(&ballot_style_template.district_ordering)    
  def district_ordering
    ballot_rule.district_ordering
  end
  
  # Supplies the sorting algorithm for contests
  # contests.sort(&ballot_style_template.contest_ordering)    
  def contest_ordering
    ballot_rule.contest_ordering
  end

  # Supplies the sorting algorithm for questions
  # questions.sort(&ballot_style_template.question_ordering)    
  def question_ordering
    ballot_rule.question_ordering
  end
  
  # Supplies the sorting algorithm for candidates
  # candidates.sort(&ballot_style_template.candidate_ordering)    
  def candidate_ordering
    ballot_rule.candidate_ordering
  end

  def contest_include_party(contest)
    ballot_rule.contest_include_party(contest)
  end
  
  # used for collection select
  # creates a set of 
  def ballot_rules
    rule_struct = Struct.new(:id, :display_name)
    rule_map  = TTV::BallotRule::Base.rules.map{ |rule| rule_struct.new(rule.simple_class_name, rule.display_name) }

    # puts "TGD: rule_map = #{rule_map.inspect}"
    rule_map
  end

  # given an election create a BallotConfig instance that will used in
  # ballot rendering
  def ballot_config(election)
    # TODO: refactor this after this BallotStyleTemplate belongs_to
    # an election.
    
    # TODO: make the ballot style belong to this ballot style template
    case BallotStyle.find(ballot_style).ballot_style_code
    when "nh"
      NhBallot::BallotConfig.new(election, self)
    else
      # TODO: Make this the default BallotConfig
      # it will replace the older DefaultBallot::BallotConfig
      # This DcBallot::BallotConfig implements Ballot Styles.
     DcBallot::BallotConfig.new(election, self)
    end
  end
end
