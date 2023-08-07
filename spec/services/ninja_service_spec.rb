require 'rails_helper'

RSpec.describe 'Ninja Service Spec' do
  describe 'Ninja Service Test' do
    it 'returns aqi for specific city', :vcr do
      aqi = NinjaService.new.city_aqi('Paris')
      expect(aqi).to be_a(Hash)
    end
  end
end

