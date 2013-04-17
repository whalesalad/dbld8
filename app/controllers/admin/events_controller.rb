class Admin::EventsController < AdminController

  def index
    @events = Event.not_registrations.includes(:user, :related).page(params[:page]).per(50)
  end

end
