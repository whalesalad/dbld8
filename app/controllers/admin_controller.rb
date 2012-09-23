require 'date'

class AdminController < ApplicationController
  skip_before_filter :require_token_auth
  
  before_filter :force_ssl if Rails.env.production?
  before_filter :authenticate if Rails.env.production?
  
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
