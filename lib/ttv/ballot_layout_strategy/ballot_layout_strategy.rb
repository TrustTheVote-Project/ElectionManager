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
        
        def create_by_display_name(dname, &block)
         self.find_by_display(name).new(&block)
        end

        def display_name
          "#{self.name.demodulize} Ballot Layout"
        end

      end
      

    end # end class methods

  end
end
