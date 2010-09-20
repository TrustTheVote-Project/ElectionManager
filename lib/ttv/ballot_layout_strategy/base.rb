module TTV
  module BallotLayoutStrategy
    class Base
      
      class << self
        
        def inherited(child)
          strategies << child
        end
        
        def strategies
          @strategies ||= []
        end
        
        def all
          strategies
        end

        def find_class(klass)
          qual_klass = nil
          
          if klass.class == ::String
            qual_klass = "#{self.parent}::#{klass}".constantize
          else
            qual_klass = klass
          end
          strategies.find{ |s| s == qual_klass}
        end
        
        def create(klass, &block)
          find_class(klass).new(&block)
        end
        
        def find_class_by_display_name(display_name)
          cname = display_name.split[0]
          self.find_class(cname)
        end
        
        def create_by_display_name(display_name, &block)
          find_class_by_display_name(display_name).new(&block)
        end

        def display_name
          "#{self.name.demodulize} Ballot Layout"
        end

      end # end class methods

      def initialize(election, precinct_split)
      end
      
      def district_ordering(d1,d2)
        top proc d1 <=> d2
      end
      
      def contest_ordering
      end
      
      def question_ordering
      end

      def candidate_ordering
      end
end # end Base class

  end
  
end
