class EmailUserAuthenticator < UserAuthenticator
  def initialize(params)
    super(params)

    user = User.find_by_email(params[:email])

    # No user warning
    if user.nil?
      @error = "A user does not exist for the email address specified."
    end 

    # Try and authenticate the user that we found
    if user && user.authenticate(params[:password])
      @user = user
    else
      @error = "The password specified was incorrect."
    end
  end
  
end