require 'koala'

class FacebookUserAuthenticator < UserAuthenticator
  def initialize(params)
    super(params)

    graph = Koala::Facebook::API.new(params[:facebook_access_token])
    
    # Perform a Facebook API call to see if the user exists.
    begin
      me = graph.get_object('me', { :fields => 'id' })
    rescue Koala::Facebook::APIError => exc
      @error = "There was an API error from Facebook: #{exc}"
    else
      @user = User.find_by_facebook_id(me['id'])
      
      if @user.nil?
        @error = {
          :error => "No Facebook User was found for this facebook_access_token.",
          :code => "NO_FACEBOOK_USER"
        }
      else
        update_access_token
      end
    end
  end

  def update_access_token
    unless user.facebook_access_token == params[:facebook_access_token]
      user.facebook_access_token = params[:facebook_access_token]
      user.save!
    end
  end
  
end