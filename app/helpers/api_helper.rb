module ApiHelper
  
  def matching_interests_with(user)
    return user.interests if user == @authenticated_user

    common_interests = (user.interests.pluck(:id) & @authenticated_user.interests.pluck(:id))
    user.interests.map do |interest|
      interest.tap { |n| n.matched = common_interests.include?(n.id) }
    end
  end

end