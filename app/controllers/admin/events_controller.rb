class Admin::EventsController < AdminController

  def index
    @events = Event.order('created_at DESC').page(params[:page]).per(50)
  end

end
