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
      if params[:import_file].nil? 
        flash[:error] = "Import failed because file was not specified."
        redirect_to :back
        return
      end
      
      begin
        @import_obj = YAML.load(params[:import_file])
      rescue
        # Not of type YAML. Try XML.
        flash[:error] = 'Ballot is not YAML.'
        return
      end
      audit = TTV::Audit.new(@import_obj, [], current_context.jurisdiction)
      @hash = audit.hash
      @alerts = audit.alerts
      render
    end
  end
  
  def import

  end

  def do_import
    
  end

end