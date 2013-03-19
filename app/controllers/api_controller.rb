class ApiController < ActionController::Base
  respond_to :json
  
  before_filter :require_token_auth
  after_filter :add_who_am_i_header if Rails.env.development?

  # rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  rescue_from ActiveRecord::RecordInvalid, :with => :record_invalid

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

  def unauthorized!
    json_unauthorized "The authenticated user does not have permission to do this."
  end

  private

  def require_token_auth
    authenticate_or_request_with_http_token do |token, options|
      token = AuthToken.find_by_token(token)
      return head :unauthorized unless token
      @authenticated_user = token.user
    end
  end

  def add_who_am_i_header
    response.headers['DBLD8-Who-Am-I'] = "#{@authenticated_user.full_name}, ID.#{@authenticated_user.id}"
  end

  def record_invalid(error)
    json_error error.message and return
  end

end