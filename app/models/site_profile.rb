class SiteProfile < ActiveRecord::Base


  include TimeStampable

  before_save :time_stamp, :extract_geocode

  def SiteProfile.first
    SiteProfile.find(:all).first || SiteProfile.new
  end

  def extract_geocode
    latlong = /&ll=[^&]*/
    slatlong = /&sll=[^&]*/
    #    puts "input=" + self.geocode
    if self.geocode
      result = latlong.match(self.geocode).to_s
      #      puts "result= " + result
      if result != ""
        self.geocode = result[4,result.length]
      else
        result = slatlong.match(self.geocode).to_s
        if result != ""
          self.geocode = result[5,result.length]
        end
      end
    end
  end

  def self.reset
    Dir.chdir(RAILS_ROOT) do
      system("cd #{Dir.pwd}; rake db:initialise")
    end
  end

end
