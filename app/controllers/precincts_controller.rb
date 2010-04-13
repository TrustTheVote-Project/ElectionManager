require 'abstract_ballot'
CHECKBOX = "\xE2\x98\x90" # "☐"
class PrecinctsController < ApplicationController

  def index
    @precincts = Precinct.paginate(:per_page => 10, :page => params[:page])
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
      style = BallotStyle.find(ballot_style_template.ballot_style).ballot_style_code
      lang = Language.find(ballot_style_template.default_language).code
      instruction_text = ballot_style_template.instruction_text
      state_seal = ballot_style_template.state_graphic
      state_signature = ballot_style_template.state_signature_image
      begin
          pdfBallot = AbstractBallot.create(election, precinct, style, lang, instruction_text, state_seal, state_signature)
          title = precinct.display_name.gsub(/ /, "_").camelize + " Ballot.pdf"
          send_data pdfBallot, :filename => title, :type => "application/pdf", :disposition => "inline"
      rescue Exception => ex
       flash[:error] = "precinct_controller - #{ex.message}"
       redirect_to precincts_election_path election
      end
    else
      flash[:error] = "A Ballot Style Template must be selected for this election before a ballot can be generated."
      redirect_to election_path election
    end
    
   
    

  end
end
