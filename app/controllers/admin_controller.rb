require 'date'

class AdminController < ApplicationController  
  before_filter :force_ssl unless Rails.env.development?
  before_filter :authenticate unless Rails.env.development?
  
  layout 'admin'

  def index
    redirect_to admin_users_url
  end

  protected

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == 'admin' && password == "Go Belluba!"
    end
  end

  def force_ssl
    unless request.ssl?
      redirect_to :protocol => 'https'
    end
  end
end
