class VotingMethodsController < ApplicationController

  def index
    @voting_methods = VotingMethod.all
  end

  def show
    @voting_method = VotingMethod.find(params[:id])
  end

  def new
    @voting_method = VotingMethod.new
  end

  def edit
    @voting_method = VotingMethod.find(params[:id])
  end

  def create
    @voting_method = VotingMethod.new(params[:voting_method])

    if @voting_method.save
      flash[:notice] = 'VotingMethod was successfully created.'
      redirect_to @voting_method
    else
      render :action => "new"
    end
  end

  def update
    @voting_method = VotingMethod.find(params[:id])

    if @voting_method.update_attributes(params[:voting_method])
      flash[:notice] = 'VotingMethod was successfully updated.'
      redirect_to(@voting_method) 
    else
      render :action => "edit" 
    end
  end

  def destroy
    @voting_method = VotingMethod.find(params[:id])
    @voting_method.destroy
    redirect_to(voting_methods_url)
  end

end
