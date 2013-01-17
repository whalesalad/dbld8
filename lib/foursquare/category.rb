module Foursquare
  class Category
        
    def initialize(json)
      @json = json
    end

    def to_s
      name
    end
    
    def name
      @json["name"]
    end
    
    def plural_name
      @json["pluralName"]
    end
    
    def icon
      [@json['icon']['prefix'], @json['icon']['suffix']].join "%s"
    end
    
    # array
    def parents
      @json["parents"]
    end
    
    def primary?
      @json["primary"] == true
    end
    
  end
end
