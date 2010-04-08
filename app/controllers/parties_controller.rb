class PartiesController < ApplicationController

  def index
    @parties = Party.paginate(:per_page => 10, :page => params[:page])
  end

  def show
    @party = Party.find(params[:id])
  end

  def new
    @party = Party.new
  end

  def edit
    @party = Party.find(params[:id])
  end

  def create
    @party = Party.new(params[:party])

    if @party.save
      flash[:notice] = 'Party was successfully created.'
      redirect_to(@party) 
    else
      render :action => "new"
    end
  end

  def update
    @party = Party.find(params[:id])

    if @party.update_attributes(params[:party])
      flash[:notice] = 'Party was successfully updated.'
      redirect_to(@party)
    else
      render :action => "edit"
    end
  end

  def destroy
    @party = Party.find(params[:id])
    @party.destroy
    redirect_to(parties_url)
  end
  
end
