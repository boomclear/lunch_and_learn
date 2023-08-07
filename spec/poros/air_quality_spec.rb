require 'rails_helper'

RSpec.describe 'Air Quality Poro' do
  describe 'Air Quality Object' do
    it 'has attributes' do
      aq = AirQuality.new("Paris", {overall_aqi: 1, "PM2.5": {concentration: 1}, CO: {concentration: 1}})

      expect(aq.city).to eq("Paris")
      expect(aq.aqi).to eq(1)
      expect(aq.pm25_concentration).to eq(1)
      expect(aq.co_concentration).to eq(1)
    end
  end
end