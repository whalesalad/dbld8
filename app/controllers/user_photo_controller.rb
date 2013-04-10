class UserPhotoController < ApiController
  before_filter :get_photo, :only => [:show, :update]

  def show
    respond_with @photo
  end

  def create
    @photo = UserPhoto.new
    
    if params[:crop_x].present?
      @photo.crop_x = params[:crop_x]
      @photo.crop_y = params[:crop_y]
      @photo.crop_w = params[:crop_w]
      @photo.crop_h = params[:crop_h]
    end

    @photo.image = params[:image]

    @photo.user = @authenticated_user
    
    resp = if @photo.save
      { :status => :created, :location => :me_photo }
    else
      { :status => :unprocessable_entity }
    end

    respond_with(@photo, resp)
  end

  def update
    require_params(params[:user_photo], :crop_x, :crop_y, :crop_w, :crop_h)
    
    @photo.update_attributes(params[:user_photo])

    resp = if @photo.save
      { :status => :created, :location => :me_photo }
    else
      { :status => :unprocessable_entity }
    end

    respond_with(@photo, resp)
  end

  # Returns the user's current facebook photo
  def facebook
    @photo = LargeFacebookPhoto.new(@authenticated_user)
    respond_with @photo
  end

  # Sets the user's current photo to their facebook photo
  def pull_facebook
    @photo = @authenticated_user.build_facebook_photo

    if params[:crop_x].present?
      @photo.crop_x = params[:crop_x]
      @photo.crop_y = params[:crop_y]
      @photo.crop_w = params[:crop_w]
      @photo.crop_h = params[:crop_h]
    end

    resp = if @photo.save
      { :status => :created, :location => :me_photo }
    else
      { :status => :unprocessable_entity }
    end

    respond_with(@photo, resp)
  end

  protected

  def get_photo
    @photo = @authenticated_user.photo
  end

end
