require 'abstract_ballot'
CHECKBOX = "\xE2\x98\x90" # "☐"
class PrecinctsController < ApplicationController

  def index
    @precincts = Precinct.all
  end

  def show
    @precinct = Precinct.find(params[:id])
  end

  def new
    @precinct = Precinct.new
  end

  def edit
    @precinct = Precinct.find(params[:id])
  end

  def create
    @precinct = Precinct.new(params[:precinct])

    if @precinct.save
      flash[:notice] = 'Precinct was successfully created.'
      redirect_to(@precinct)
    else
      render :action => "new" 
    end
  end

  def update
    @precinct = Precinct.find(params[:id])

    if @precinct.update_attributes(params[:precinct])
      flash[:notice] = 'Precinct was successfully updated.'
      redirect_to(@precinct) 
    else
      render :action => "edit" 
    end
  end

  def destroy
    @precinct = Precinct.find(params[:id])
    @precinct.destroy
    redirect_to(precincts_url) 
  end
  
  def ballot
    election = Election.find(params[:election_id])
    precinct = Precinct.find(params[:id])
    unless election.ballot_style_template_id == nil
      ballot_style_template = BallotStyleTemplate.find(election.ballot_style_template_id)
      style = ballot_style_template.ballot_style 
    else
      style = 'default'
    end
    
    lang = params[:lang] || 'en'
    
    begin
        pdfBallot = AbstractBallot.create(election, precinct, style, lang)
        title = precinct.display_name.gsub(/ /, "_").camelize + " Ballot.pdf"
        send_data pdfBallot, :filename => title, :type => "application/pdf", :disposition => "inline"
    rescue Exception => ex
     flash[:error] = "precinct_controller - #{ex.message}"
     redirect_to precincts_election_path election
   end
  end
end
