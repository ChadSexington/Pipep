class UsersController < ApplicationController

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def auth
    auth = User.authenticate(auth_params[:username], auth_params[:password]) 
    if auth
      session[:user] = auth.id
      flash[:success] = "FUCK YEA WELCOME BACK MY NIGGA"
      redirect_to :torrents 
    else
      flash[:error] = "Make like a tree and get the fuck outta here."
      redirect_to '/login'
    end 
  end

  def login
    @user = User.new
  end

  def logout
    session[:user] = nil
    if session[:user]
      flash[:error] = "Could not log out D:"
      redirect_to :back
    else
      flash[:success] = "The lack of your presence leaves a hole only excessive eating can fill."
      redirect_to :root
    end
  end

private

  def auth_params
    params.permit(:username, :password)
  end

end
