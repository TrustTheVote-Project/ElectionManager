class BallotsController < ApplicationController
  
  before_filter :election, :precinct_split, :only => [:show]
  
  def index
  end
  
  def show
    if @election && @precinct
      @ballot = Ballot.find_or_create(@election, @precinct_split)
    else
      @ballot = Ballot.find(params[:id])
    end
    # get the ballot file naming strategy, Proc object, for the active
    # ballot rule
    ballot_rule = BallotStyleTemplate.find(@ballot.election.ballot_style_template_id).ballot_rule
    title =  @ballot.filename(&ballot_rule.ballot_filename) << ".pdf"
    
    send_data @ballot.render_pdf, :filename => title, :type => "application/pdf", :disposition => 'inline'
    # TODO: use respond_to to generate pdf
    #     respond_to do |format| 
    #       format.html # show.html.erb
    #       format.xml { render :xml => @ballot }
    #     end
  end

  private
  def election
    @election = Election.find(params[:election_id])  if params[:election_id]
  end
  
  def precinct_split
    @precinct_split = Precinct_Split(param(:precinct_split_id)) if params[:precinct_split_id]
  end
end
