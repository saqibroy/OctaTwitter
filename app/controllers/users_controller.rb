class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy,:correct_user]
  before_action :logged_in_user,only: [:edit,:update,:index,:show,:following,:followers]
  before_action :correct_user,only: [:edit,:update]
  before_action :admin_user, only: :destroy

  # GET /users
  # GET /users.json
  def index
    data=User.where(["name LIKE ?","%#{params[:search]}%"]).paginate(page: params[:page])
    if data
      @users=data
    else
      flash[:danger]="No data found"
    end
    
    #@users = User.paginate(page: params[:page])
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @microposts=@user.microposts.paginate(page: params[:page])
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.save
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account!"
      redirect_to root_url
    else
      render 'new' 
    end
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile Updated"
      redirect_to current_user
    else
      render 'edit'
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    flash[:success]="user deleted!"
    redirect_to users_url
  end
  def following
    @title= "following"
    @user=User.find(params[:id])
    @users=@user.following.paginate(page: params[:page])
    render 'show_follow'
  end
  def followers
    @title= "followers"
    @user=User.find(params[:id])
    @users=@user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name,:email,:password,:password_confirmation,:profile_pic)
    end
    
    def correct_user 
      unless current_user? @user
        flash[:success]="you cant edit other user's profile!"
        redirect_to root_url
      end
    end
    def admin_user
redirect_to(root_url) unless  current_user.admin?
end
end
