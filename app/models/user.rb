class User < ActiveRecord::Base
  attr_accessible :bio, :birthday, :email, :first_name, :gender, :interested_in, :last_name, :password, :single
end
