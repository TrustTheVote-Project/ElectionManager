class ElectionsController < ApplicationController
  
 authorize_resource
  
  def index
    current_context.reset
    @elections = Election.paginate(:per_page => 10, :page => params[:page])
    redirect_to :action => 'new' if @elections.empty?
    @election = UserSession.find.election if UserSession.find
  end

  def show
    params[:ballot_page] ||= 1
    @election = Election.find(params[:id], :include => [ 
      { :district_set => :districts }, 
      { :contests => :candidates },
      :questions, 
      ])
    current_context.election = @election
    @contests = @election.contests.paginate(:per_page => 10, :page => params[:page], :order => 'position')
    @questions = @election.questions.paginate(:per_page => 10, :page => params[:page])
    @precinct_splits = PrecinctSplit.precinct_jurisdiction_id_is(@election.district_set_id).paginate(:per_page => 10, :page => params[:page])
  end

  def new
    @election = Election.new
  end

  def edit
    @election = Election.find(params[:id])
    @dist_sets = DistrictSet.find(:all)
    render :partial => 'edit', :locals => { :election => @election } if request.xhr?
  end

  def create
    @election = Election.new(params[:election])
    if @election.save
      flash[:notice] = 'Election was successfully created.'
      redirect_to @election
    else
      render :action => "new" 
    end
  end

  # responds to AJAX updates too
  def update
    @election = Election.find(params[:id])
    success = @election.update_attributes(params[:election])
    flash[:notice] = 'Election was successfully updated.' if success
    if request.xhr?
      edit_id = "#{dom_id(@election)}_edit"
      static_id = "#{dom_id(@election)}_static"
      render :update do |page|
        if success
          page.remove edit_id
          page.replace static_id, :partial => 'static', :locals => { :election => @election }
        else
          @dist_sets = DistrictSet.find(:all)
          page.replace edit_id, :partial => 'edit', :locals => { :election => @election }
        end
      end
    elsif success
      redirect_to @election
    else
     render :action => "edit"
    end
  end

  def destroy
    @election = Election.find(params[:id])
    @election.destroy
    redirect_to elections_url
  end

  def import
    begin
      if params[:importFile].nil? 
        flash[:error] = "Import failed because file was not specified."
        redirect_to :back
      else
        @election = TTV::ImportExport.import(params[:importFile])
        flash[:notice] = "Election import was successful. Here is your new election."
        redirect_to @election
      end
    rescue ActionController::RedirectBackError => ex
      redirect_to elections_url
    rescue Exception => ex
      raise ex
      flash[:error] = "Import error: #{ex.message}";
      redirect_to elections_url
    end
  end
  
  def import_yml
    begin
      if params[:importFile].nil? 
        flash[:error] = "Import failed because file was not specified."
        redirect_to :back
      else
        import_handler = TTV::YAMLImport.new(params[:importFile])
        @election = import_handler.import
        flash[:notice] = "Election import was successful. Here is your new election."
        redirect_to @election
      end
    rescue ActionController::RedirectBackError => ex
      redirect_to elections_url
    rescue Exception => ex
      raise ex
      flash[:error] = "Import error: #{ex.message}";
      redirect_to elections_url
    end
  end
  
  def export
    @election = Election.find(params[:id])
    title = @election.display_name.gsub(/ /, "_").camelize
    headers["Content-disposition"] = "attachment;filename=\"#{title}.xml\""
    render :xml => @election
  end

  def precincts
    @election = Election.find(params[:id])
  end
  
  def translate
    @election = Election.find(params[:id])
    TTV::PDFBallot.translate(@election, params[:lang])
    flash[:notice] = "Election was successfully translated"
    redirect_to precincts_election_url
  end
  
  def ballot_map
    @election = Election.find(params[:id])
    respond_to do |format|
      format.yml { 
          headers["Content-Disposition"] = "attachment; filename=\"#{@election.display_name}-ballotmap.yml\"" 
          render :text => @election.generate_ballot_map.to_yaml, :content_type => 'text/x-yml' }
      format.xml { 
          headers["Content-Disposition"] = "attachment; filename=\"#{@election.display_name}-ballotmap\"" 
          render :xml => @election.generate_ballot_map.to_xml }
    end
  end
  
  def ballot_proofing
    @election = Election.find(params[:id])
    respond_to do |format|
      format.csv { 
        headers["Content-Disposition"] = "attachment; filename=\"#{@election.display_name}-ballot-proof.csv\"" 
        render :text => @election.generate_ballot_proofing, :content_type => Mime::Type.lookup_by_extension("csv").to_s
      }
      format.html {}
    end
  end
end

