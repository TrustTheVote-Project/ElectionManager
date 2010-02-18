class DistrictsController < ApplicationController

  def index
    @districts = District.all
  end

  def show
    @district = District.find(params[:id])
  end

  def new
    @district = District.new
    @district.election_id = params[:election_id]
    @election = params[:election_id]
  end

  def edit
    @district = District.find(params[:id])
    @district_sets = {}
    DistrictSet.find(:all).collect { |ds| @district_sets[ds.display_name] = ds.id}
  end

  def create
    @district = District.new(params[:district])
    @election = params[:election_id]
    if @district.save
      flash[:notice] = 'District was successfully created.'
      redirect_to(@district)
    else
      render :action => "new"
    end
  end

  def update
    @district = District.find(params[:id])
    handle_district_sets
    if @district.update_attributes(params[:district])
      flash[:notice] = 'District was successfully updated.'
      redirect_to districts_url
    else
      render :action => "edit"
    end
  end

  def destroy
    @district = District.find(params[:id])
    @district.destroy
    redirect_to(districts_url)
  end
  
  private
  
  def handle_district_sets
    if params['district_sets']
      @district.district_sets.clear
      chosen_sets = params[:district_sets].map { |id| DistrictSet.find(id)}
      @district.district_sets << chosen_sets
    end
  end
end
