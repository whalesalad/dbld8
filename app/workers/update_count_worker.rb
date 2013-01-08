class UpdateCounts
  include Sidekiq::Worker

  # example, user changes their location. 
  # need to decrement the counter of the old and increment the new
  def perform(class_and_properties)
    m, property = class_and_properties.split ':'
    
    model = m.constantize

    model.pluck(:id).each { |id| model.reset_counters(id, property) }
  end
end