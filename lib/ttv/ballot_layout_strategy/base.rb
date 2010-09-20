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
      
      def initialize
      end
      
      def district_ordering
        return lambda do |d1, d2|
          d1.position <=> d2.position
        end
      end
      
      def contest_ordering
        return lambda do |c1, c2|
          c1.position <=> c2.position
        end
      end
      
      def question_ordering
        return lambda do |q1, q2|
          q1.position <=> q2.position
        end
      end

      def candidate_ordering
        return lambda do |c1, c2|
          c1.position <=> c2.position
        end
      end
      
    end # end Base class
    
  end
end
