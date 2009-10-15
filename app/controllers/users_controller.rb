class UsersController < ApplicationController

  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
    @user = current_user
    #    logger.info("User is #{@user}")
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      begin
        Notifier.deliver_registration_confirmation(@user)
      rescue => ex
        flash[:error] = "Confirmation email not sent. #{ex.message}"
      end
      flash[:notice] = 'Registration successful.'
      redirect_to root_url
    else
      render :action => "new" 
    end
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = 'Update successful.'
      redirect_to root_url
    else
      render :action => "edit" 
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to(users_url) 
  end
end
