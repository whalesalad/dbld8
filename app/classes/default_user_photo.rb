class DefaultUserPhoto
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def thumb
    user.default_photo
  end

  def small
    thumb
  end

  def medium
    thumb
  end

  def as_json(options={})
    {
      :id => '000',
      :thumb => thumb,
      :small => small,
      :medium => medium,
      :note => "This user does not have a photo."
    }
  end
end