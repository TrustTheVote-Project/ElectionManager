class DistrictsController < ApplicationController

  def index
    @districts = District.all
  end

  def show
    @district = District.find(params[:id])
    @election = params[:election_id]
  end

  def new
    @district = District.new
    @district.election_id = params[:election_id]
    @election = params[:election_id]
  end

  def edit
    @district = District.find(params[:id])
    @election = params[:election_id]
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
    @election = params[:election_id]
    if @district.update_attributes(params[:district])
      flash[:notice] = 'District was successfully updated.'
      redirect_to(@district)
    else
      render :action => "edit"
    end
  end

  def destroy
    @district = District.find(params[:id])
    @district.destroy
    redirect_to(districts_url)
  end
end
