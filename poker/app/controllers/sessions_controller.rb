class SessionsController < ApplicationController
  def new
  end

  def create
   @user = User.find_by(username: params[:username])
   if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect_to '/'
   else
      redirect_to '/login'
   end
  end

  def login
  end

  def welcome
  end

  def destroy
    helpers.log_out
    redirect_to '/'
  end
end
