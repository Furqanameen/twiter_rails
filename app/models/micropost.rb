class Micropost < ApplicationRecord
  belongs_to :user
  default_scope ->{ order(created_at: :desc)}
  validates :user_id,presence: true
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true ,length:{maximum:300}
  # validate :picture_size
  

  # private
  # 	def picture_size
  # 		if picture_size > 5.megabytes
  # 			errors.add(:picture,"should be less then 5MB")
  # 		end
  # 	end

end
