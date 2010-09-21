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
  
  validates_presence_of [:display_name], :on => :create, :message => "can't be blank"
  
  has_attached_file :instructions_image,
  :styles => {
    :thumb=> "100x100#",
    :small  => "150x150>"
    # :medium => "300x300>",
    #       :large =>   "400x400>" 
  }
  
  def after_initialize

    # default page params
    self.page ||= { :size =>  "LETTER",
      :layout => :portrait,
      :background => '000000',
      :margin => { :top => 0, :right => 0, :bottom => 0, :left => 0}
    }

    default_frame
    default_ballot_layout
    default_contents
    
  end
  
  def default_frame

    self.frame ||= {
      :margin => {:top => 0, :right => 0, :bottom => 0, :left => 0},
      :border =>  {:width => 0, :color => '000000', :style => :solid},
      :content =>{
        :top => { :width => 50, :text => "Sample Ballot", :rotate => 0, :graphics => nil },
        :right => { :width => 47,:text => " tom D was here", :rotate => 90, :graphics => nil },
        :bottom => { :width => 190,:text => "Sample Ballot", :rotate => 0, :graphics => nil },
        :left => { :width => 67,:text => "    132301113              Sample Ballot", :rotate => 90, :graphics => nil }
      }}
    
    # default frame content header is the name of the precinct
    self.frame[:content][:top][:graphics] ||= <<-'FRAME_TOP'     
      text = @precinct.display_name
      middle_x = @pdf.bounds.right/2 - @pdf.width_of(text)/2
      middle_y = @pdf.bounds.top - @frame[:content][:top][:width]/2 + @pdf.height_of(text)/2
      @pdf.font("Times-Roman", :size => 18, :style => :bold) do
        @pdf.draw_text text, :at => [middle_x, middle_y]
      end
    FRAME_TOP
    
    # default frame content footerr is the name of the precinct
    self.frame[:content][:bottom][:graphics] ||= <<-'FRAME_BOT'     
      text = @precinct.display_name
      middle_x = @pdf.bounds.right/2 - @pdf.width_of(text)/2
      middle_y = @pdf.bounds.bottom + @frame[:content][:bottom][:width]/2 - @pdf.height_of(text)/2
      @pdf.font("Times-Roman", :size => 18, :style => :bold) do
        @pdf.draw_text text, :at => [middle_x, middle_y]
      end
    FRAME_BOT

  end
  
  def default_ballot_layout
    self.ballot_layout ||= { :create_A_headers => true} 
  end
  
  def default_contents
    
    self.contents ||= {
      :border => {:width => 1, :color => '000000', :style => :dashed},
      :header =>{
        :width => 498,
        :height => 154,
        :margin => {:top => 0, :right => 0, :bottom => 0, :left => 0},
        :border => {:width => 0, :color => '000000', :style => :solid},
        :text => "Header Text", # this will be Rich Text in Prawn 1.0
        :background_color => '000000',
        :graphics => nil
      },

      :body =>{
        :width => 1.0, # % width of ballot contents box
        :height => 0.7, # % height of ballot contents box
        :margin => {:top => 0, :right => 0, :bottom => 0, :left => 0},
        :border => {:width => 0, :color => '000000', :style => :solid},
        :text => "Body Text", # this will be Rich Text in Prawn 1.0
        :background_color => '000000',
        :graphics => nil
      },
      :footer =>{
        :width => 1.0, # % width of ballot contents box
        :height => 0.15, # % height of ballot contents box
        :margin => {:top => 0, :right => 0, :bottom => 0, :left => 0},
        :border => {:width => 0, :color => 'FF0000', :style => :solid},
        :text => "Footer Text", # this will be Rich Text in Prawn 1.0
        :background_color => '#00FF00',
        :graphics => nil
      },
      
    }
    

    # header, minus instructions
    contents[:header][:graphics] ||= <<-'HEADER'
      
      # draw yellow background rectangle
      orig_color = @pdf.fill_color
      @pdf.fill_color('F0E68C')
      rect_x = 36
      rect_y= @pdf.bounds.top - 14
      rect_width = 430
      rect_height = 53
      @pdf.fill_rectangle([rect_x, rect_y], rect_width, rect_height)
      @pdf.fill_color(orig_color)
      
      # Election Date is used in header
      edate = Date.parse("#{@election.start_date}").strftime("%A, %B %d, %Y" )
      
      @pdf.move_down 14
      @pdf.text "#{@template.ballot_title}\n#{@election.display_name}", :align => :center, :style => :bold
      @pdf.text "#{@election.district_set.display_name}\n#{edate}", :align => :center
      
      # instructions
      @pdf.bounding_box [0, @pdf.bounds.top - 82], :width => @pdf.bounds.width, :height => @pdf.bounds.height - 82 do
        
        @pdf.stroke_bounds
        
        @pdf.move_down 3
        @pdf.font "Helvetica", :style => :bold, :size => 10 do
          @pdf.text "INSTRUCTIONS TO VOTER", :align => :center
        end
        
        @pdf.move_down 5
        instr_text = "1. TO VOTE YOU MUST DARKEN THE OVAL TO THE LEFT OF YOUR CHOICE COMPLETELY. An oval darkened to the left of the name of any candidate indicates a vote for that candidate.\n2. Use only a pencil or blue or black medium ball point pen.\n3. If you make a mistake DO NOT ERASE. Ask for a new ballot.\n4. For a Write-in candidate, write the name of the person on the line and darken the oval."
        y = @pdf.bounds.top - @pdf.height_of("TEXT")
        @pdf.text instr_text, :size => 8
      end
      
    HEADER
  end # default_contents
  
  # given a hash of styles update the page, frame and contents attributes/hashes.
  def update_styles(styles_hash)
    page.merge!(styles_hash[:page]) if styles_hash[:page]
    frame.merge!(styles_hash[:frame]) if styles_hash[:frame]
    contents.merge!(styles_hash[:contents]) if styles_hash[:contents]
    ballot_layout.merge!(styles_hash[:ballot_layout]) if styles_hash[:ballot_layout]
    save!

  end
  
  def reload_style
    logger.debug "TGD: reloading ballot style file #{ballot_style_file.inspect}"
    load_style(self.ballot_style_file) if self.ballot_style_file
  end
  
  def load_style(filename)
    self.ballot_style_file = filename
    
    style_hash = YAML.load(filename)

    logger.debug "TGD: style_hash[:page] = #{style_hash[:page].inspect}"
    
    logger.debug "="*30    
    logger.debug "\nTGD: style_hash[:frame][:margin] = #{style_hash[:frame][:margin].inspect}"
    logger.debug "\nTGD: style_hash[:frame][:content][:top] = #{style_hash[:frame][:content][:top].inspect}"
    logger.debug "\nTGD: style_hash[:frame][:content][:right] = #{style_hash[:frame][:content][:right].inspect}"
    logger.debug "\nTGD: style_hash[:frame][:content][:bottom] = #{style_hash[:frame][:content][:bottom].inspect}"
    logger.debug "\nTGD: style_hash[:frame][:content][:left] = #{style_hash[:frame][:content][:left].inspect}"
    logger.debug "\nTGD: style_hash[:frame][:border] = #{style_hash[:frame][:border].inspect}"
    
    logger.debug "="*30    
    logger.debug "\nTGD: style_hash[:contents][:body] = #{style_hash[:contents][:body].inspect}"
    logger.debug "\nTGD: style_hash[:contents][:footer] = #{style_hash[:contents][:footer].inspect}"
    logger.debug "\nTGD: style_hash[:contents][:header] = #{style_hash[:contents][:header].inspect}"
    logger.debug "\nTGD: style_hash[:contents][:border] = #{style_hash[:contents][:border].inspect}"
    
    update_styles(style_hash)
  end

  
  def to_yaml
    { :page => page, :frame => frame, :contents => contents, :ballot_layout => ballot_layout}.to_yaml
  end

  def create_A_ballot_headers?
    ballot_layout && ballot_layout[:create_A_headers]
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
  
  # used for collection select
  # creates a set of 
  def ballot_rules
    rule_struct = Struct.new(:id, :display_name)
    rule_map  = TTV::BallotRule::Base.rules.map{ |rule| rule_struct.new(rule.simple_class_name, rule.display_name) }

    # puts "TGD: rule_map = #{rule_map.inspect}"
    rule_map
  end
end
