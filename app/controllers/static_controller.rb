class StaticController < ApplicationController
  PAGE_SLUGS = %W(about terms privacy help)
  DOWNLOAD_SLUGS = %W(download itunes appstore app)

  def show
    slug = params[:slug].downcase
    if PAGE_SLUGS.include?(slug)
      render "static/#{params[:slug]}" and return
    elsif DOWNLOAD_SLUGS.include?(slug)
      redirect_to download_url and return
    end
    redirect_to root_url
  end

  def download
    Analytics.track(user_id: '000', event: 'Download URL Visited')
    redirect_to Rails.configuration.app_store_url
  end

end 