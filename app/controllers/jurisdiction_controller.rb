class JurisdictionController < ApplicationController
  
  def index
    @jurisdiction = session[:jurisdiction]
    if @jurisdiction.nil?
      redirect_to :action => :change_jurisdiction
    else
      @old_jurisd = @jurisdiction.id
      @elections = DistrictSet.find(@old_jurisd).elections.paginate(:per_page => 10, :page => params[:page])
    end  
  end
  
  def change_jurisdiction
    @district_sets = DistrictSet.paginate(:per_page => 10, :page => params[:page])
  end
  
  def set_jurisdiction
    session[:jurisdiction] = DistrictSet.find(params[:id])
    redirect_to :action => :index
  end
 
end
