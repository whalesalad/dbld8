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
      update_access_token if @user
    end
  end

  def update_access_token
    unless user.facebook_access_token == params[:facebook_access_token]
      user.facebook_access_token = params[:facebook_access_token]
      user.save!
    end
  end
  
end