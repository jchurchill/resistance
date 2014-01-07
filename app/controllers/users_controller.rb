class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_filter :login_required, :only => [:show, :edit]

  # GET /users
  def index
    @users = User.all
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /user
  def show
    @user = current_user
  end

  # GET /users/1/edit
  # GET /user/edit
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to account_url, notice: 'User was successfully created.'
    else
      render :action => :new
    end
  end

  # PATCH/PUT /user
  def update
    if @user.update_attributes(user_params)
      redirect_to account_url, notice: 'User was successfully updated.'
    else
      render :action => :edit
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :login, :email, :password, :password_confirmation)
    end

    # Require a logged-in session with this method
    # Method current_user is defined in ApplicationController.rb
    def login_required  
    unless current_user  
      flash[:error] = 'You must be logged in to view this page.'  
      redirect_to new_user_session_path  
    end  
  end
end
