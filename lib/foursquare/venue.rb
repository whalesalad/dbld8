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
        response['groups'][0]['items'].map do |all|
          self.new all["venue"]
        end
      end
    end

    attr_reader :json

    def initialize(json, location=nil)
      @json = json

      unless location.nil?
        @location = location
      end
    end

    def to_s
      "#{name} - #{location}"
    end

    def id
      @json["id"]
    end

    def name
      @json["name"]
    end

    def location
      @location ||= new_location_from_json(@json["location"])
    end

    def location_from_json(location_json)
      Location.new(:name => name,
                   :place => name,
                   :latitude => location_json["lat"],
                   :longitude => location_json["lng"],
                   :country => location_json["cc"],
                   :locality => location_json["city"],
                   :foursquare_id => id)
    end

  end
end