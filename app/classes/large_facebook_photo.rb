class LargeFacebookPhoto
  attr_accessor :user, :original
  
  def initialize(user)
    @user = user
  end

  def original
    user.large_facebook_photo
  end

  def as_json(options={})
    {
      id: '000',
      thumb: original,
      small: original,
      medium: original,
      original: original
    }
  end
end