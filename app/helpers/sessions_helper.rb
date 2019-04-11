module SessionsHelper
	def log_in(user)
		session[:user_id]=user.ids

		# If i use it as like give me erors   session[:user_id]=user.id   
	end

	def current_user?(user)
		user==current_user
	end
	# Return the curent loged-in user
	# Returns the user corresponding to the remember token cookie.
	def current_user
		if (user_id=session[:user_id]) 
			@current_user ||=User.find_by(id: user_id)
		elsif (user_id=cookies.signed[:user_id])
			# raise    # The test still pass so this brance is currently un tested
			user=User.find_by(id: user_id)
			if user && user.authenticated?(:remember,cookies[:remember_token])
				log_in user
				@current_user=user
			end
		end
		
	end


	# Remember a user in a presistent session.
	def remember(user)
		user.remember
		cookies.permanent.signed[:user_id]=user.id
		cookies.permanent[:remember_token]=user.remember_token
		
	end
	def logged_in?
		!current_user.nil?
		
	end

	# Forget persistent sessions
	def forget(user)
		# user.forget             # this line is showing erors when i do logout.........
		cookies.delete(:user_id)
		cookies.delete(:remember_token)
		
	end

	def log_out
		forget(current_user)
		session.delete(:user_id)
		@current_user = nil
	end

	# Redirect to store location(or to the default)
	def redirect_back_or(default)
		redirect_to(session[:forwarding_url] || default)
		session.delete(:forwarding_url)
	end

	# Store the urltrying to be accessed
	def store_location
		session[:forwarding_url]=request.orignal_url 
		if request.get?
		end
		
	end
end
