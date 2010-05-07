class JurisdictionController < ApplicationController
  
  def index
    if !current_context.jurisdiction?
      redirect_to :action => :change_jurisdiction
    else
      current_context.election = nil
      @elections = current_context.jurisdiction.elections.paginate(:per_page => 10, :page => params[:page])
    end  
  end
  
  def change_jurisdiction
    @district_sets = DistrictSet.paginate(:per_page => 10, :page => params[:page])
  end
  
  def set_jurisdiction
    current_context.jurisdiction = DistrictSet.find(params[:id])
    redirect_to :action => :index
  end
 
end
