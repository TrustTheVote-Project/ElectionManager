require 'abstract_ballot'
require 'rubygems'
require 'zip/zip'

CHECKBOX = "\xE2\x98\x90" # "☐"

class PrecinctsController < ApplicationController

  def index
    @precincts = Precinct.paginate(:per_page => 10, :page => params[:page])
    current_context.reset
  end

  def show
    @precinct = Precinct.find(params[:id])
    current_context.precinct = @precinct
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
       #begin
             new_ballot = election.render_ballot(election, precinct, ballot_style_template)
             #RENDER BASED ON MEDIUM CHOSEN   
             if new_ballot[:medium_id] == 0
                send_data new_ballot[:pdfBallot], :filename => new_ballot[:fileName], :type => "application/pdf", :disposition => 'attachment'
             elsif new_ballot[:medium_id] == 1
               render :text => 'This is where we will generate html ballot'
             else
               flash[:error] = "Please edit ballot style template to include a output a medium and then try again."
               redirect_to election_path election
             end
       #  rescue Exception => ex
       #    flash[:error] = "precinct_controller - #{ex.message}"
       #    redirect_to precincts_election_path election
       # end
     else
       flash[:error] = "A Ballot Style Template must be selected for this election before a ballot can be generated."
       redirect_to election_path election
     end    

  end
  
  
  def ballots
     election = Election.find(params[:election_id])
     precincts = election.district_set.precincts
     
     unless election.ballot_style_template_id == nil
       ballot_style_template = BallotStyleTemplate.find(election.ballot_style_template_id)
       begin
        ballots_array = election.render_ballots(election, precincts, ballot_style_template)
        zipped_ballots = zip_ballots(ballots_array)
        send_file zipped_ballots, :type => 'application/zip', :disposition => 'application', :filename => "ballots-#{Time.now}.zip"
       
      rescue Exception => ex
        flash[:error] = "precinct_controller - #{ex.message}"
        redirect_to precincts_election_path election
      end
     else
       flash[:error] = "A Ballot Style Template must be selected for this election before any ballots can be generated."
       redirect_to election_path election
     end    

  end
  
  
  def zip_ballots(ballots_array)
     temp_file = "tmp/ballot_zips/ballots-#{Time.now}.zip"
     Zip::ZipFile.open(temp_file, Zip::ZipFile::CREATE) {
        |zipfile|
         ballots_array.each do |new_ballot|
           zipfile.get_output_stream(new_ballot[:fileName]) { |f| f.puts new_ballot[:pdfBallot] }
         end
       }
    return temp_file
  end
end
