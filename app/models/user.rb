class User < ApplicationRecord

	has_many :microposts, dependent: :destroy
	has_many :active_relationships,  class_name:  "Relationship",
	                               foreign_key: "follower_id",
	                               dependent:   :destroy
	has_many :passive_relationships, class_name:  "Relationship",
	                               foreign_key: "followed_id",
	                               dependent:   :destroy
	has_many :following, through: :active_relationships,  source: :followed
	has_many :followers, through: :passive_relationships, source: :follower
	attr_accessor :remember_token, :activation_token, :reset_token
	before_save   :downcase_email
	before_create :create_activation_digest
	validates :name,presence: true,length: { maximum:51 }
	# VALID_EAMIL_REGEX= /\A[\W+\-.]+@[a-z\d\-\.]+\.[a-z]+\z/i
	# VALID_EAMIL_REGEX= /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	# validates :email,presence: true,length: { maximum:244 },format:{with: VALID_EAMIL_REGEX},uniqueness: { case_sensitive: false }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  	validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password,presence:true ,length:{minimum:6},allow_nil: true


	# Returns true if the given token matches the digest.
	def authenticated?(attribute, token)
		digest = send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
	end


		#Return the hash digest of the given strings.
	def User.digest(string)
		cost=ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MNI_COST :
													BCrypt::Engine.cost
		BCrypt::Password.create(string,cost: cost)
	end

	#Return a random tokens
	def User.new_token
    	SecureRandom.urlsafe_base64
  	end
	# end

	# Remembers a user in the database for use in persistent sessions.
	def remember
		self.remember_token=User.new_token
		update_attribute(:remember_digest,User.digest(remember_token))
	end

	def authenticated?(remember_token)
		BCrypt::Password.new(remember_digest).is_password?(remember_token)
		
	end

	# Activate an account
	def activate
		# update_columns(activated: FILL_IN, activated_at: FILL_IN)
		update_attribute(:activated,    true)
		update_attribute(:activated_at,  Time.zon.now)
	end

	# Send activation email
	def send_activation_email
		UserMailer.account_activation(self).deliver_now
		
	end
	def create_reset_digest
		self.reset_token=User.new_token
		update_attribute(:reset_digest,  User.digest(reset_token))
		# update_columns(reset_digest: FILL_IN,reset_sent_at: FILL_IN)
    	update_attribute(:reset_sent_at, Time.zone.now)
	end
	def send_password_reset_email
		UserMailer.password_reset(self).deliver_now
	end

	def feed
		# Micropost.where("user_id=?",id)
		following_ids = "SELECT followed_id FROM relationships
                     	WHERE  follower_id = :user_id"
	    Micropost.where("user_id IN (#{following_ids})
	                     OR user_id = :user_id", user_id: id)
			
	end
	def follow(other_user)
		following<<other_user
	end
	def unfollow(other_user)
		following.delete(other_user)
	end
	# Returns true if the current user is following the other user.
	def following?(other_user)
		following.include?(other_user)
	end

	private
		def downcase_email
			self.email=email.downcase
		end
		def create_activation_digest
			self.activation_token=User.new_token
			self.activation_digest=User.digest(activation_token)
		end

	# Forgets a user
	def forget
		update_attribute(:remember_digest, nil)
	end

	# Returns true if a password reset has expired.
	def password_rest_expired
		reset_sent_at < 12.hours.ago
		
	end

end
