class Admin::EventsController < AdminController

  def index
    @events = Event.order('created_at DESC')
  end

end
