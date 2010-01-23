module TTV
  module PDFBallot
    module Aiga
      class BallotConfig < TTV::PDFBallot::Default::BallotConfig
        def initialize(style, lang, election)
          super
        end      
      end
    end
  end
end
