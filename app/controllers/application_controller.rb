class ApplicationController < ActionController::Base
  # protect_from_forgery
  # skip_before_filter :verify_authenticity_token
  before_filter :require_token_auth

  def json_error(error_message)
    render json: { :error => error_message }, :status => 500 and return
  end

  def json_not_found(error_message)
    render json: { :error => error_message }, :status => 404 and return
  end

  def json_unauthorized(error_message)
    render json: { :error => error_message }, :status => 401 and return
  end

  def authenticated_user
    @authenticated_user || nil
  end

  private

  def require_token_auth
    authenticate_or_request_with_http_token do |token, options|
      token = AuthToken.find_by_token(token)
      return head :unauthorized unless token
      @authenticated_user = token.user
    end
  end
end
