class PasswordResetsController < ApplicationController
	before_action :get_user, only: [:edit,:update]
	before_action :valid_user, only: [:edit, :update]
	before_action :check_expiration, only: [:edit, :update]
  def new
  end

  def edit
  end
  def update
  	if params[:user][:password].empty?
  		@user.errors.add(:password, "can't  be empty")
  		render 'edit'
  	elsif @user.update_attributes(user_param)
  		log_in @user
  		flash[:success]="password has been reset"
  		redirect_to @user
  	else
  		render 'edit'
  	end
  		
  	
  end

  def create
  	@user=User.find_by(email:params[:password_reset][:email].downcase)
  	if @user
  		@user.create_reset_digest
  		@user.send_password_reset_email
  		flash[:info]="Email sent with password instructions"
  		redirect_to root_url
  	else
  		flash.now[:danger]="Email address not found"
  		render 'new'
  	end
  	
  end

  private
  	def user_param
  		params.require(:user).permit(:password,:password_confirmation)
  		
  	end
  	def get_user
  		@user=User.find_by(email: params[:email])
  	end

  	def valid_user
  		unless (@user && @user.activated? && @user.authenticated?(:reset,params[:id]))
  			redirect_to root_url
  		end
  	end
  	def check_expiration
  		if @user.password_reset_expired?
  			flash[:danger]= "password reset has been Expired"
  			redirect_to new_password_rest_url
  		end
  	end

end
