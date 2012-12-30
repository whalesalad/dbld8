class DefaultUserPhoto
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def thumb
    user.default_photo
  end

  def as_json(options={})
    {
      :id => '000',
      :thumb => thumb,
      :note => "This user does not have a photo."
    }
  end
end