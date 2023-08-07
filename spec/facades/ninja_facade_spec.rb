require 'rails_helper'

RSpec.describe 'Ninja Facade Test' do 
  describe 'Ninja Facade Methods' do 
    it 'service method' do 
      ninja = NinjaFacade.new.service 

      expect(ninja).to be_a(NinjaService)
    end
    it 'list of Ninja method', :vcr do 
      ninja = NinjaFacade.new.city_aqi("Paris")

      expect(ninja).to be_a(AirQuality)
    end
  end
end