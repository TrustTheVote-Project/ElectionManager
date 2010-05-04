class JurisdictionController < ApplicationController
  
  def index
    if !current_context.current_jurisdiction?
      redirect_to :action => :change_jurisdiction
    else
      @old_jurisd = current_context.current_jurisdiction
      @elections = current_context.elections.paginate(:per_page => 10, :page => params[:page])
    end  
  end
  
  def change_jurisdiction
    @district_sets = DistrictSet.paginate(:per_page => 10, :page => params[:page])
  end
  
  def set_jurisdiction
    current_context.current_jurisdiction = DistrictSet.find(params[:id])
    redirect_to :action => :index
  end
 
end
