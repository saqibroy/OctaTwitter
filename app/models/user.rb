class User < ActiveRecord::Base
	attr_accessor :activation_token, :reset_token
    mount_uploader :profile_pic, PictureUploader
	before_create :create_activatin_digest
	before_save	   { self.email	= email.downcase	}
    validates	:name,	presence:	true,	length:	{	maximum:	50	}
    VALID_EMAIL_REGEX	=	/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates	:email,	presence:	true,	length:	{	maximum:	255	},
    format:	    {	with:	VALID_EMAIL_REGEX	},
    uniqueness:	{	case_sensitive:	false	}
	has_secure_password
    has_many :microposts, dependent: :destroy
    has_many :active_relationships,class_name: "Relationship",foreign_key: "follower_id",dependent: :destroy
    has_many :following, through: :active_relationships, source: :followed
    has_many :passive_relationships, class_name: "Relationship",foreign_key: "followed_id",dependent: :destroy
    has_many :followers, through: :passive_relationships, source: :follower
    #   Returns true    if  the given   token   matches the digest.
    def authenticated?(attribute,   token)
        digest  =   send("#{attribute}_digest")
        return  false   if  digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end
    #   Returns the hash    digest  of  the given   string.
	def	User.digest(string)
        cost	=	ActiveModel::SecurePassword.min_cost	?	BCrypt::Engine::MIN_COST	:
        BCrypt::Engine.cost
        BCrypt::Password.create(string,	cost:	cost)
    end
        #	Returns	a	random	token.
    def	User.new_token
        SecureRandom.urlsafe_base64
    end
	def create_activatin_digest
		self.activation_token=User.new_token
		self.activation_digest=User.digest(activation_token)
	end
    def activate
        update_attribute(:activated, true)
        update_attribute(:activated_at, Time.zone.now)
    end
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end
    def create_reset_digest
        self.reset_token=User.new_token
        update_attribute(:reset_digest, User.digest(reset_digest))
        update_attribute(:reset_sent_at, Time.zone.now)
    end
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
        #UserMailer.deliver_password_reset(self)
    end
    def password_reset_expired?
        reset_sent_at   <   2.hours.ago
    end
    def feed
        following_ids   =   "SELECT followed_id FROM    relationships
                             WHERE follower_id = :user_id"
        Micropost.where("user_id    IN  (#{following_ids})
                         OR  user_id =   :user_id",  user_id:    id)
    end
    def follow(other_user)
        active_relationships.create(followed_id: other_user.id)
    end
    def unfollow(other_user)
        active_relationships.find_by(followed_id: other_user.id).destroy
    end
    def following?(other_user)
        following.include?(other_user)
    end
end
