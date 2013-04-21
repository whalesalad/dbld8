class StaticController < ApplicationController
  skip_filter :require_token_auth, :all

  def about

  end

  def terms

  end

  def privacy
    
  end

  def help
    
  end

end 