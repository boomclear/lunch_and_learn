require 'rails_helper'

RSpec.describe 'Air Quality Index' do
  describe 'Shows air quality' do
    it 'shows air quality for a country capital', :vcr do
      get '/api/v1/air_quality?country=France'

      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(json_response[:data]).to have_key(:id)
      expect(json_response[:data]).to have_key(:type)
      expect(json_response[:data][:id]).to eq('null')
      expect(json_response[:data][:type]).to eq('air_quality')
      expect(json_response[:data][:id]).to be_a(String)
      expect(json_response[:data][:type]).to be_a(String)
      expect(json_response[:data]).to have_key(:city)
      expect(json_response[:data][:attributes]).to have_key(:aqi)
      expect(json_response[:data][:attributes]).to have_key(:pm25_concentration)
      expect(json_response[:data][:attributes]).to have_key(:co_concentration)
      expect(json_response[:data][:attributes][:aqi]).to be_a(String)
      expect(json_response[:data][:attributes][:pm25_concentration]).to be_a(String)
      expect(json_response[:data][:attributes][:co_concentration]).to be_a(String)
    end
  end
end
