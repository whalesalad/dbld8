class CronController < ApplicationController  
  respond_to :json
  
  skip_before_filter :require_token_auth

  AVAILABLE_TASKS = %w(apn_feedback)

  def run_task
    unless params[:task].present? && AVAILABLE_TASKS.include?(params[:task])
      return json_error "Please specify a valid task to run."
    end

    # Currently this is the only task that can be run.
    PushFeedbackWorker.perform_async

    render json: { success: true } and return
  end

end
