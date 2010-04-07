class BallotStylesController < ApplicationController
  def index
    @styles = TTV::PDFBallotStyle.list
    render :layout => 'none'        
  end
end
