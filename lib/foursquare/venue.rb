# I will be inputting a point, and expecting back a list of 
# - cities (Great Falls, VA)
# - places (Starbucks Coffee, Great Falls, VA)

module Foursquare
  class Venue
    
    class << self
      def find(venue_id, location=nil)
        response = Foursquare.get "/venues/#{venue_id}"
        self.new(response['venue'], location)
      end

      def explore(params)
        response = Foursquare.get "/venues/explore", params
        parse_venues_from_response(response)
      end

      private

      def parse_venues_from_response(response)
        venues = response['groups'][0]['items'].map do |all|
          self.new all["venue"]
        end

        venues.sort_by! { |v| v.distance }
      end
    end

    attr_reader :json, :location

    def initialize(json, location=nil)
      @json = json

      unless location.nil?
        @location = location
      else
        @location = find_or_create_location
      end

      @location.distance = distance
    end

    def to_s
      "#{name} - #{location.name}"
    end

    def id
      @json["id"]
    end

    def name
      @json["name"]
    end

    def city
      @json["location"]["city"]
    end

    def state
      @json["location"]["state"]
    end

    def country_code
      @json["location"]["cc"]
    end

    def distance
      @json["location"]["distance"]
    end

    def location
      @location
    end

    def sanitize_field(text)
      case text
      when nil
        nil
      when text == text.upcase
        text.capitalize
      end

      text
    end

    def find_or_create_location
      Location.find_or_create_by_foursquare_id(:foursquare_id => id,
        :place => name,
        :latitude => @json["location"]["lat"],
        :longitude => @json["location"]["lng"],
        :locality => sanitize_field(city),
        :admin_code => state,
        :country => country_code)
    end

  end
end