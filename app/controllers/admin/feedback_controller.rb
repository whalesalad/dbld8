class Admin::FeedbackController < AdminController
  before_filter :get_feedback, :only => [:show, :destroy]

  def index
    @title = 'Feedback'
    @feedback = Feedback.order('created_at DESC').page(params[:page]).per(50)
  end

  def show
    
  end

  def destroy
    @feedback.destroy
    
    redirect_to admin_feedback_path, 
      flash: { success: "Successfully deleted feedback message #{@feedback}." }
  end

  protected

  def get_feedback
    @feedback = Feedback.find(params[:id])
  end
end
