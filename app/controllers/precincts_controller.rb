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
    @election = Election.find(params[:election_id])
    @precinct = Precinct.find(params[:id])
    lang = params[:lang] || 'en'
    style = params[:style] || 'default'
    @ballot_translation = PDFBallotStyle.get_ballot_translation(style, lang)
    @ballot_config = YAML::load(File.read("#{RAILS_ROOT}/app/ballots/#{style}/lang/#{lang}/ballot.yml"))
    @hpad= 3
    @hpad2 = 6
    @vpad = 3
    @vpad2 = 6
   
    begin
       #pdfBallot = AbstractBallot.create(election, precinct, style, lang)
       #title = precinct.display_name.gsub(/ /, "_").camelize + " Ballot.pdf"
       #send_data pdfBallot, :filename => title, :type => "application/pdf", :disposition => "inline"
       
       respond_to do |format|
             format.html
             format.pdf do
               render :pdf => "#{@election.display_name} Ballot",
                      #:template => "show.pdf.erb", # OPTIONAL
                      :layout => "pdf.html", # OPTIONAL
                      :wkhtmltopdf => 'lib/wkhtmltopdf', # OPTIONAL, path to binary
                      :show_as_html => !params[:debug].blank? #OPTIONAL, maybe you just want to allow debuging in development environment?
                      
             end
           end
    rescue Exception => ex
      puts "precinct_controller - #{ex.message}"
       flash[:error] = "precinct_controller - #{ex.message}"
       #redirect_to precincts_election_path election
     end
    
  end
  
  
  
  

end
