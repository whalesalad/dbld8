class ApplicationController < ActionController::Base
  # protect_from_forgery
  # skip_before_filter :verify_authenticity_token
  before_filter :restrict_access

  def json_error(error_message)
    return render json: { :error => error_message }, :status => 500
  end

  def json_not_found(error_message)
    return render json: { :error => error_message }, :status => 404
  end

  def authenticated_user
    @authenticated_user || nil
  end

  private

  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
      token = AuthToken.find_by_token(token)
      return head :unauthorized unless token
      @authenticated_user = token.user
    end
  end
end
