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

  private

  def restrict_access
    token = AuthToken.find_by_token(params[:token])
    head :unauthorized unless token
  end
end
