# class CountriesFacade
#   def service
#     CountriesService.new
#   end

#   def list_of_countries
#     list = service.country_list
#     list.map do |country|
#       country[:name][:common]
#     end
#   end

# end

require 'rails_helper'

RSpec.describe 'Countries Facade Test' do 
  describe 'Countries Facade Methods' do 
    it 'service method' do 
      country = CountriesFacade.new.service 

      expect(country).to be_a(CountriesService)
    end
    it 'list of countries method', :vcr do 
      country = CountriesFacade.new.list_of_countries

      expect(country).to be_a(Array)
      expect(country.count).to eq(250)
    end
  end
end