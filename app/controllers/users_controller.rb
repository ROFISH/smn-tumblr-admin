class UsersController < ApplicationController
  before_action :require_rofish

  def require_rofish
    if session[:username] != "ROFISH"
      redirect_to :root
    end
  end

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.create(user_params)
    redirect_to action: :index
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to action: :index
  end

private
  def user_params
    params[:user].permit(:name)
  end
end
