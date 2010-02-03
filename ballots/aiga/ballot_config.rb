module TTV
module PDFBallot
module Aiga
  class BallotConfig < TTV::PDFBallot::Default::BallotConfig
    def initialize(style, lang, election, scanner)
      super
    end      

    def render_column_instructions(columns, page)
    end

  end
end
end
end
