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
        
        venues = response['groups'].first['items'].map {|i| i['venue']}
        
        parse_venues_from_response(venues)
      end

      def search(params)
        response = Foursquare.get "/venues/search", params
        parse_venues_from_response(response['venues'])
      end

      private

      def parse_venues_from_response(raw_venues)
        venues = []

        return venues if raw_venues.count == 0
        
        raw_venues.each do |venue|
          next if venue['stats']['usersCount'] < 5
          next unless venue.has_key? 'location'
          venues << self.new(venue)
        end

        venues.compact.sort_by! { |v| v.distance }
      end
    end

    attr_reader :json, :location
    attr_accessor :categories

    def initialize(json, location=nil)
      @json = json

      unless location.nil?
        @location = location
      end
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
      (@json["location"]["cc"] || 'US').upcase
    end

    def address
      @json["location"]["address"]
    end

    def distance
      @json["location"]["distance"]
    end

    def location
      @location ||= find_or_create_location
    end

    def categories
      @categories ||= @json["categories"].map { |c| Foursquare::Category.new(c) }
    end

    def primary_category
      return nil if categories.blank?
      @primary_category ||= categories.select { |category| category.primary? }.try(:first)
    end
    
    def icon
      primary_category ? primary_category.icon : nil
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
      params = {
        :foursquare_id => id,
        :foursquare_icon => icon,
        :venue => name,
        :latitude => @json["location"]["lat"],
        :longitude => @json["location"]["lng"],
        :locality => sanitize_field(city),
        :state => state,
        :address => address,
        :country => country_code
      }

      l = Location.find_or_create_by_foursquare_id(params)
      l.distance = distance
      
      return l
    end

  end
end