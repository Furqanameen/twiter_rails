class UsersController < ApplicationController

  before_action :logged_in_user, only: [:index,:edit, :update,:destroy,:following,:followers ]
  before_action :correct_user, only:[:edit,:update]
  before_action :admin_user, only: :destroy

  def index
    # @user=User.all
    @users=User.paginate(page: params[:page])
    # @users= User.where(activated: FILL_IN).paginate(page: params[:page])
  end
  def new
  	@user=User.new
  end
  def show  
  	@user = User.find(params[:id])
    @microposts=@user.microposts.paginate(page: params[:page])
    # redirect_to root_url and return unless FILL_IN
      
  	# debugger
  end
  def following
    @title="Following"
    @user=User.find(params[:id])
    @users=@user.following.paginate(page: params[:page])
    render 'show_follow'
    
  end
  def followers
    @title="Followers"
    @user=User.find(params[:id])
    @users=@user.followers.paginate(page: params[:page])
    render 'show_follow'
    
  end

  def create
  	@user=User.new(params_create)
  	# if @user.valid
  	if @user.save
      @user.send_activation_email
      # UserMailer.account_activation(@user).deliver_now
      # log_in @user
       flash[:info]="please chek your email to activate your account!"
       redirect_to root_url
       # redirect_to @user
  	else
  		render 'new'
    end

  end
  def update
    @user=User.find(params[:id])
    if @user.update_attributes(params_create)
      flash[:success]="Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
    
  end
  def destroy
    @user=User.find(params[:id]).destroy
    flash[:success]="user deleted"
    redirect_to users_url
    
  end
  def edit
    @user=User.find(params[:id])
    
  end
  private 
    def params_create
  	 params.require(:user).permit(:name,:email,:password,:password_confirmation)
  	
    end
    # Before filters

    # Confirms a logged-in user.
    # def logged_in_user
    #   unless logged_in?
    #     store_location
    #     flash[:danger]="Pleasr log in"
    #     redirect_to login_url
        
    #   end
      
    # end
    def correct_user
      @user=User.find(params[:id])
      redirect_to(root_url) 
      unless current_user?(@user)
        
      end
    end
    def admin_user
      redirect_to(root_url) 
      unless current_user.admin?
        
      end
      
    end
end
