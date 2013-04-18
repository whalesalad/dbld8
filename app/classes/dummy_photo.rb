class DefaultUserPhoto
  attr_accessor :user, :thumb, :small, :medium
  
  def initialize(user)
    @user = user
  end

  def thumb
    @thumb ||= DummyPhoto.new(user.default_thumb)
  end

  def small
    @small ||= DummyPhoto.new(user.default_photo)
  end

  def medium
    small
  end

  def image
    small
  end

  def as_json(options={})
    {
      :id => '000',
      :thumb => thumb,
      :small => small,
      :medium => medium,
      :note => I18n.t('misc.no_user_photo')
    }
  end
end

class DummyPhoto
  attr_accessor :photo

  def initialize(photo)
    @photo = photo
  end

  def to_s
    @photo
  end

  def url
    @photo
  end
end