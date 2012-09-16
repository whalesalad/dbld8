class UserPhotoController < ApplicationController
  before_filter :set_user
  
  respond_to :json

  def show
    respond_with @user.photo
  end

  def create
    @photo = UserPhoto.new
    @photo.image = params[:image]
    @photo.user = @user
    
    if @photo.save
      respond_with(@photo, status: :created, :location => :me_photo)
    else
      respond_with(@photo, status: :unprocessable_entity)
    end
  end

  protected

  def set_user
    @user = authenticated_user
  end

end
