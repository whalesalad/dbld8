class UserAuthenticator
  attr_accessor :params, :user, :error

  def initialize(params, error=nil)
    @params = params
    @error = error if error
  end

  def self.from_params(params)
    if params.has_key? :facebook_access_token
      return FacebookUserAuthenticator.new params
    elsif (params.keys & %w(email password)).count == 2
      return EmailUserAuthenticator.new params
    end

    self.new params, "You must specify either an email/password " \
      "pair or facebook_access_token to authenticate."
  end

  def authenticated?
    user.present?
  end

  def find_or_create_token
    AuthToken.find_or_create_by_user_id(user.id)
  end

end