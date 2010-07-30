class JurisdictionsController < ApplicationController
  
  def current
    if !current_context.jurisdiction?
      redirect_to :action => :change
    else
      current_context.election = nil
      @elections = current_context.jurisdiction.elections.paginate(:per_page => 10, :page => params[:page])
      render :elections
    end  
  end
  
  def elections
    current_context.election = nil
    @elections = current_context.jurisdiction.elections.paginate(:per_page => 10, :page => params[:page])
  end
 
  
  def change
    @district_sets = DistrictSet.paginate(:per_page => 10, :page => params[:page])
  end
  
  def set
    current_context.jurisdiction = DistrictSet.find(params[:id])
    redirect_to :action => :elections
  end
 
  def audit
    begin
      if session[:import_hash].nil? and params[:import_file].nil? 
        flash[:error] = "Import failed because file was not specified."
        redirect_to :back
        return
      end
      
      if params[:import_file]
        session[:import_hash] = nil
        session[:import_alerts] = nil
        begin
          @import_obj = YAML.load(params[:import_file])
        rescue
          # Not of type YAML. Try XML.
          flash[:error] = 'Ballot is not YAML.'
          return
        end
      end
      
      audit = TTV::Audit.new(@import_obj, [], current_context.jurisdiction) unless session[:import_alerts]
      audit = TTV::Audit.new(session[:import_hash], session[:import_alerts], current_context.jurisdiction) if session[:import_alerts] && session[:import_hash]
      audit.apply_alerts
      audit.audit
      session[:import_hash] = audit.hash # TODO: put in database, pass id through session
      session[:import_alerts] = audit.alerts
      @alerts = session[:import_alerts]
    end
  end
  
  def import

  end

  def do_import
    # Apply params choices to session[:import_alerts]
    session[:import_alerts].each { |alert| 
      choice = params.find{|param| param[0] == alert.type.to_s}
      alert.choice = choice[1].to_sym if choice
    }
    
    if session[:import_alerts].size == 0
      import_obj = TTV::HashImport.new(@session[:import_hash])
      import_obj.import
      flash[:notice] = "Import successful."
      render
    else
      redirect_to :action => :audit # Fails because needs to be PUT
    end
    


  end

end