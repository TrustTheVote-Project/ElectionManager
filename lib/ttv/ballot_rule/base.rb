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
          c1.position <=> c2.position
        end
      end
      
      def contest_include_party
        true
      end

      def candidate_display_name(candidate)
        candidate.display_name
      end
      
    end # end Base class
    
  end
end
