class JurisdElectionsController < ApplicationController
  
  def list
    @jurisdiction = session[:jurisdiction]
    @dist_sets = DistrictSet.all
    if @jurisdiction.nil?
      @old_jurisd = 0
      render :action => :set_jurisdiction
    else
      @old_jurisd = @jurisdiction.id
      @elections = DistrictSet.find(@old_jurisd).elections.paginate(:per_page => 10, :page => params[:page])
      render :action => :list_elections
    end  
  end
  
  def set_jurisdiction
    session[:jurisdiction] = DistrictSet.find(params[:jurisdiction])
    redirect_to juris_elections_url
  end
  
end
