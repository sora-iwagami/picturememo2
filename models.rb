require 'bundler/setup'
Bundler.require
require './photoUploader'

ActiveRecord::Base.establish_connection

class Place < ActiveRecord::Base
    mount_uploader :photo, PhotoUploader
    belongs_to :category
    belongs_to :user
end    

class Category < ActiveRecord::Base
    has_many :places
end

class User < ActiveRecord::Base
    has_many :group_users, dependent: :destroy
    has_many :groups, through: :group_users
    
    has_many :places
    belongs_to :color
    has_secure_password
    # validates :mail,
        # presence: true
        # format: {with:/\ A. +@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+\z/}
    # validates :password,
    #     format: {with:/(?=.*?[a-z])(?=.*?[0-9])/},
    #     length: {in: 5..20}
end

class Color < ActiveRecord::Base
    has_many :users, dependent: :destroy
    
end

class Group < ActiveRecord::Base
    has_many :group_users, dependent: :destroy
    has_many :users, through: :group_users
    
    has_many :places, dependent: :destroy
end
    
class GroupUser < ActiveRecord::Base
    belongs_to :group
    belongs_to :user
end    

