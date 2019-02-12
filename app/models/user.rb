require './config/environment'
class User < ActiveRecord::Base 
has_many :loans

has_secure_password
validates :username, presence: true, length: {maximum: 255}
validates :email, presence: true, uniqueness: {case_sensitive: false}, length: {maximum: 255}
  
  def slug
    username.downcase.gsub(" ","-")
  end

  def self.find_by_slug(slug)
    User.all.find{|user| user.slug == slug}
  end


end 