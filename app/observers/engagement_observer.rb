class EngagementObserver < ActiveRecord::Observer
  
  def after_commit(engagement)
    if engagement.send(:transaction_include_action?, :create)
      # Create engagement events for the user and the wing, both earn points
      NewEngagementEvent.create(:user => engagement.user, :related => engagement)
      NewEngagementEvent.create(:user => engagement.wing, :related => engagement)
    end

    # if message.send(:transaction_include_action?, :destroy)
    # 
    # end    
  end

end