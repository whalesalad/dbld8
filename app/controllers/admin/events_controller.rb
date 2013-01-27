class Admin::EventsController < AdminController

  def index
    @events = Event.includes(:user, :related).order('created_at DESC').page(params[:page]).per(50)
  end

end
