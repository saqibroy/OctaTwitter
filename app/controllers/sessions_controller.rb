class SessionsController < ApplicationController
  def new
  end
  def create
  	user= User.find_by(email: params[:session][:email].downcase)
  	if user && user.authenticate(params[:session][:password])
      if user.activated?
  		 log_in user
  		 flash[:success]="Welcome #{user.name}!"
  		 redirect_back_or user
      else
        message   = "Account  not activated.  "
        message +=  "Check  your  email for the activation  link."
        flash[:warning] = message
        redirect_to root_url
      end
  	else
  		flash[:danger]="Invalid email/password!"
  		render 'new'
  	end
  end
  def destroy
  	log_out
  	flash[:success]="You are successfully loged out!"
  	redirect_to root_url
  end
end
