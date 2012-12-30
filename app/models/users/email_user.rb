class EmailUser < User
  validates_presence_of :password, :email, :on => :create
  
  def default_photo
    "http://static.dbld8.com/misc/no-photo.png"
  end
end