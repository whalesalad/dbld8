# http://vombat.tumblr.com/post/8191942021/responding-with-non-empty-json-when-updating-a-resource
# https://github.com/rails/rails/blob/master/actionpack/lib/action_controller/metal/responder.rb#L205

module ActionController
  class Responder
    def api_behavior(error)
      raise error unless resourceful?

      if get?
        display resource
      elsif post?
        display resource, :status => :created, :location => api_location
      elsif put?
        display resource, :status => :ok
      else
        head :no_content
      end
    end
  end
end