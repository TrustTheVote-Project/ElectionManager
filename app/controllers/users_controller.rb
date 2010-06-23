class UsersController < ApplicationController

  authorize_resource

  def index
    @users = User.paginate(:per_page => 10, :page => params[:page])
    redirect_to :action => 'new' if @users.empty?
  end

  def show
    @user = User.find(params[:id])
  end

  def register
    @user = User.new
  end
  
  def new
    @user = User.new
  end

  def edit
    # @user = current_user
    @user = User.find(params[:id])
    #    logger.info("User is #{@user}")
  end

  def create
    @user = User.new(params[:user])

    # default role for new users is 'standard'
    @user.roles << UserRole.new(:name => 'standard')
    
    if @user.save
      begin
        Notifier.deliver_registration_confirmation(@user)
      rescue => ex
        flash[:error] = "Confirmation email not sent. #{ex.message}"
      end
      flash[:notice] = 'Successfully created a new user.'
      redirect_to root_url
    else
      flash[:error] = "Failed to create a new user: " << @user.errors.full_messages.join(', ')
      # redirect_to new_user_url
      redirect_to request.referer
    end
  end

  def update
    # @user = current_user
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'Update successful.'
      redirect_to users_url
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
