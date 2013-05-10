class StatsController < ApplicationController
  before_filter :require_token_auth
  before_filter :force_ssl unless Rails.env.development?
  
  respond_to :json

  def users
    @last_ten_users = User.includes(:location).last(10).reverse.map do |user|
      { 
        id: user.id,
        name: user.full_name,
        location: user.location.to_s,
        created: user.created_at.to_i
      }
    end

    render json: {
      total_users: User.count,
      total_guys: User.guys.count,
      total_girls: User.girls.count,
      last_hour: User.where("created_at > ?", 60.minutes.ago).count,
      last_day: User.where("created_at > ?", 24.hours.ago).count,
      last_ten: @last_ten_users
    }
  end

  def activities
    @last_ten_activities = Activity.includes(:location).last(10).reverse.map do |activity|
      {
        id: activity.id,
        name: "#{activity.to_s} by #{activity.participant_names}",
        location: activity.location.to_s,
        created: activity.created_at.to_i
      }
    end

    render json: {
      total_activities: Activity.count,
      last_ten: @last_ten_activities
    }
  end

  def events
    @last_ten_events = Event.not_registrations.includes(:related).last(10).reverse.map do |event|
      {
        id: event.id,
        event: event.human_name,
        detail: event.detail,
        created: event.created_at.to_i
      }
    end

    render json: {
      total_events: Event.not_registrations.count,
      last_hour: Event.not_registrations.where("created_at > ?", 60.minutes.ago).count,
      last_day: Event.not_registrations.where("created_at > ?", 24.hours.ago).count,
      last_ten: @last_ten_events
    }
  end

  def users_by_country
    @countries = User.with_location.inject(Hash.new(0)) do |country, user| 
      country[user.location.country.name] += 1
      country 
    end.reject { |country, count| count < 2 }.first(10)

    @countries = Hash[@countries.sort_by { |country, count| -count }]

    render json: @countries
  end

  private

  def require_token_auth
    authenticate_or_request_with_http_token do |token, options|
      return head :unauthorized unless token == "DOUBLEDATESTATS"
      true
    end
  end

  def force_ssl
    unless request.ssl?
      redirect_to :protocol => 'https'
    end
  end

end
