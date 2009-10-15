class DistrictTypesController < ApplicationController

  def index
    @district_types = DistrictType.all
  end

  def show
    @district_type = DistrictType.find(params[:id])
  end

  def new
    @district_type = DistrictType.new
  end

  def edit
    @district_type = DistrictType.find(params[:id])
  end

  def create
    @district_type = DistrictType.new(params[:district_type])

    if @district_type.save
      flash[:notice] = 'DistrictType was successfully created.'
      redirect_to(@district_type) 
    else
      render :action => "new" 
    end
  end

  def update
    @district_type = DistrictType.find(params[:id])

    if @district_type.update_attributes(params[:district_type])
      flash[:notice] = 'DistrictType was successfully updated.'
      redirect_to(@district_type) 
    else
      render :action => "edit" 
    end
  end

  def destroy
    @district_type = DistrictType.find(params[:id])
    @district_type.destroy
    redirect_to(district_types_url) 
  end
end
