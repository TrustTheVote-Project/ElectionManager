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
  
  def import
    
  end
  
  # 1. Receives file
  # 2. Checks XML vs. YAML
  # 3. Converts to EDH
  # 4. create Audit.new(EDH) --> id
  # 5. audit, good: do_import, alerts: int_audit
  def import_file
    begin
      if session[:import_hash].nil? and params[:import_file].nil? 
        flash[:error] = "Import failed because file was not specified."
        redirect_to :back
        return
      end
      
      if params[:import_file]
        session[:audit_obj] = nil
        begin
          edh_to_audit = YAML.load(params[:import_file])
        rescue
          # Not of type YAML. Try XML.
          flash[:error] = 'Ballot is not YAML.'
          return
        end
      end
      
      audit_obj = Audit.new(:election_data_hash => edh_to_audit, :district_set => current_context.jurisdiction)
      audit_obj.save!
      session[:audit_id] = audit_obj.id
      #audit = TTV::Audit.new(session[:import_hash], session[:import_alerts], current_context.jurisdiction) if session[:import_alerts] && session[:import_hash]
      #audit.apply_alerts
      audit_obj.audit
      
      if audit_obj.alerts.size == 0
        redirect_to :action => :do_import
      else
        redirect_to :action => :interactive_audit
      end
    end
  end
  
  # Get Audit object from DB (stored as params[:audit_id])
  # Display Audit object's Alerts
  def interactive_audit
    @alerts = Audit.find(session[:audit_id]).alerts
  end
  
  # Get Audit object from DB (stored as params[:audit_id])
  # audit.apply_alerts
  # audit, good: do_import, alerts: int_audit
  def apply_audit
    audit_obj = Audit.find(session[:audit_id])
    audit_obj.alerts.each { |alert| 
      choice = params.find{|param| param[0] == alert.alert_type}
      alert.choice = choice[1] if choice
    }
    
    audit_obj.apply_alerts
    
    if audit_obj.alerts.size == 0
      redirect_to :action => :do_import
    else
      redirect_to :action => :interactive_audit
    end
  end
  
  # Get audit obj from session
  def do_import
    import_obj = TTV::ImportEDH.new(Audit.find(session[:audit_id]).election_data_hash)
    import_obj.import
    flash[:notice] = "Import successful."
    redirect_to :action => :import
  end
end