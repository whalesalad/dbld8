class UserPhotoController < ApplicationController
  respond_to :json

  def show
    respond_with @authenticated_user.photo
  end

  def create
    @photo = UserPhoto.new
    @photo.image = params[:image]
    @photo.user = @authenticated_user
    
    resp = if @photo.save
      { :status => :created, :location => :me_photo }
    else
      { :status => :unprocessable_entity }
    end

    respond_with(@photo, resp)
  end

  def pull_facebook
    @photo = @authenticated_user.fetch_facebook_photo
    respond_with @photo, :status => :created, :location => :me_photo
  end

end
