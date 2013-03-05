# The main 'geoname' table has the following fields :
# ---------------------------------------------------
# geonameid         : integer id of record in geonames database
# name              : name of geographical point (utf8) varchar(200)
# asciiname         : name of geographical point in plain ascii characters, varchar(200)
# alternatenames    : alternatenames, comma separated varchar(5000)
# latitude          : latitude in decimal degrees (wgs84)
# longitude         : longitude in decimal degrees (wgs84)
# feature class     : see http://www.geonames.org/export/codes.html, char(1)
# feature code      : see http://www.geonames.org/export/codes.html, varchar(10)
# country code      : ISO-3166 2-letter country code, 2 characters
# cc2               : alternate country codes, comma separated, ISO-3166 2-letter country code, 60 characters
# admin1 code       : fipscode (subject to change to iso code), see exceptions below, see file admin1Codes.txt for display names of this code; varchar(20)
# admin2 code       : code for the second administrative division, a county in the US, see file admin2Codes.txt; varchar(80) 
# admin3 code       : code for third level administrative division, varchar(20)
# admin4 code       : code for fourth level administrative division, varchar(20)
# population        : bigint (8 byte int) 
# elevation         : in meters, integer
# dem               : digital elevation model, srtm3 or gtopo30, average elevation of 3''x3'' (ca 90mx90m) or 30''x30'' (ca 900mx900m) area in meters, integer. srtm processed by cgiar/ciat.
# timezone          : the timezone id (see file timeZone.txt) varchar(40)
# modification date : date of last modification in yyyy-MM-dd format

require 'csv'

namespace :dbld8 do
  #  
  task :import_geonames_cities => :environment do
    puts "Importing geonames cities..."

    cities_txt = Rails.root.join('lib', 'geonames_cities_15000.txt')

    File.open(cities_txt) do |handle|
      i = 0
      @errors = []
      @locations = []
      handle.each_line do |city_line|
        i += 1
        begin
          city = CSV.parse_line(city_line, { :col_sep => "\t" })
          params = {
            :geoname_id => city[0],
            :country => city[8], 
            :state => city[10],
            :locality => city[1],
            :latitude => city[4],
            :longitude => city[5]
          }

          @locations << Location.find_or_create_by_geoname_id(params)
        rescue
          @errors << "City on line #{i} failed."
        end
      end
    end

    if @errors.any?
      puts "There were #{@errors.size} error(s)."
      @errors.each do |e|
        puts "\t #{e}"
      end
    end

    if @locations.any?
      puts "#{@locations.size} location(s) were imported successfully."
    end

  end
end