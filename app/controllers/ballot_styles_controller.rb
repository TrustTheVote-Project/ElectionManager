class BallotStylesController < ApplicationController
  def index
    @styles = TTV::PDFBallotStyle.list
  end
end
