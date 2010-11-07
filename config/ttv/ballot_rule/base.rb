# TODO: fix this workaround for loading classes that set class
# instance variables
# needed to put this outside of directories that dev mode reloads
# automatically.
# NOTE: def reloadable?; false; end; # doesn't work

module TTV
  module BallotRule
    class Base

      # create class methods, actually methods on Base eigenclass/singleton
      class << self

        # Hook that is called when another class inherits this class
        # i.e. when a ballot rule class inherits this base class
        def inherited(subklass)
          # NOTE: trying to avoid Ruby keyword subclass here, using
          # subklass
          
          # subklass is the class that inherited from this Base class
          # Add this sub class to the list of ballot rule classes
          rules << subklass
        end

        # set of ballot rule classes
        def rules
          @rules ||= []
        end

        alias :all :rules
        
        # Find a ballot rule sub class given it's class name, e.g,
        # "VA", or the fully qualified class ::TTV::BallotRule::VA
        def find_subclass(klass)
          qual_klass = nil
          
          if klass.class == ::String
            qual_klass = "#{self.parent}::#{klass}".constantize
          else
            qual_klass = klass
          end
          rules.find{ |s| s == qual_klass}
        end

        # create an instance of a ballot rule given the class name or
        # fully qualified class 
        def create_instance(klass, &block)
          find_subclass(klass).new(&block)
        end
        
        # construct the display name of a ballot rule class
        def display_name
          "#{self.name.demodulize} Ballot Rule"
        end

        
        # returns "VA" for TTV::BallotRule::VA, "Default" for
        # TTV::BallotRule::Default
        # used in form to id this Ballot Rule class
        def simple_class_name
          "#{self.name.demodulize}"
        end

        # Find a sub class given this subclass's display_name, e.g. "VA Ballot
        # Rule"
        def find_subclass_by_display_name(display_name)
          cname = display_name.split[0]
          self.find_subclass(cname)
        end
        
        # Create an instance of a sub class given this subclass's
        # display_name, e.g."VA Ballot Rule"
        def create_instance_by_display_name(display_name, &block)
          find_subclass_by_display_name(display_name).new(&block)
        end

      end # end class methods
      
      # instance methods
      def initialize
      end
      
      # TODO: the below should be class methods?
      
      # the below ordering methods return a lambda that is converted to a
      # block, with &, and passed Enumerable#sort
      # districts.sort(&TTV::BallotRule::Base.new.district_ordering)
      # OR
      # districts.sort(&TTV::BallotRule::VA.new.district_ordering)
      def district_ordering
        # NOTE: the return is not needed here, added for emphasis/doc
        return lambda do |d1, d2|
          d1.position <=> d2.position
        end
      end
      
      # contests.sort(&TTV::BallotRule::Base.new.contest_ordering)
      def contest_ordering
        return lambda do |c1, c2|
          c1.position <=> c2.position
        end
      end
      
      # questions.sort(&TTV::BallotRule::Base.new.question_ordering)
      def question_ordering
        return lambda do |q1, q2|
          q1.position <=> q2.position
        end
      end

      # candidates.sort(&TTV::BallotRule::Base.new.candidate_ordering)
      def candidate_ordering
        return lambda do |c1, c2|
          (c1.position && c2.position) ? c1.position <=> c2.position : 0
        end
      end
      
      def contest_include_party(contest)
        true
      end

      def candidate_display_name(candidate)
        candidate.display_name
      end

      # TODO: move this rendering code out of ballot rules.
      # This should be:
      # - replaced by PDF rich text in the ballot style files
      # OR
      # - rendered in rails views that generate pdf, see prawn_to gem
      def frame_content_top(ballot_config)
      end
      def frame_content_right(ballot_config)
      end
      def frame_content_bottom(ballot_config)
      end
      def frame_content_left(ballot_config)
      end
      
      def contents_header(ballot_config)
      end
      def contents_body(ballot_config)
      end
      def contents_footer(ballot_config)
      end
      
      # Make questions display after contests
      def reorder_questions(flow_items)
        question_items = []
        other_items = []
          flow_items.each do |item|
            if item.class.name == "DefaultBallot::FlowItem::Question"
              question_items << item
            else
              other_items << item
            end
          end
          flow_items = other_items + question_items
      end
      
      # called after the flow_items,(district, contest, questions), are created
      def post_process_flow_items(template, flow_items)
        if template.ballot_layout['questions_placement'] == :at_end
          flow_items = reorder_questions(flow_items)
        end
        
        flow_items
      end # end process_flow_items
      
      # balllot filename strategy.
      # returns a Proc that get's eval'd in the scope of a ballot
      # object/model. Which allows use to use all models that can be
      # reached via a ballot when naming.  
      def ballot_filename
        # NOTE: this was originally implemented in the BallotFileNamer class
        lambda do
          "#{@precinct_split.precinct.display_name}-#{@precinct_split.display_name}".gsub(' ', '-')
        end
      end
      
    end # end Base class
    
  end
end
