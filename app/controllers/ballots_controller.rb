class BallotsController < ApplicationController
  before_filter :election, :precinct_split
  def show
    if @election && @precinct
      @ballot = Ballot.find_or_create(@election, @precinct_split)
    else
      @ballot = Ballot.find(params[:id])
    end

    respond_to do |format| 
      format.html # show.html.erb
      format.xml { render :xml => @ballot }
    end
  end

  private
  def election
    logger.debug "TGD: election = #{@election.inspect}"
    @election = Election.find(params[:election_id])    
  end
  def precinct
    logger.debug "TGD: precinct = #{@precinct.inspect}"
    precinct_split = Precinct_Split(param(:precinct_split_id))
  end
end
