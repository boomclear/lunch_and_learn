require 'rails_helper'

RSpec.describe 'Recipes Index' do
  describe 'Search for Recipes' do
    it 'Shows a list of recipes for country searched for', :vcr do
      get '/api/v1/recipes?country=thailand'

      recipes = JSON.parse(response.body, symbolize_names: true)

      expect(recipes[:data].count).to eq(20)

      expect(response).to be_successful
      recipes[:data].each do |recipe|
        expect(recipe).to have_key(:id)
        expect(recipe).to have_key(:type)
        expect(recipe[:id]).to eq('null')
        expect(recipe[:type]).to eq('recipe')

        expect(recipe[:attributes]).to have_key(:title)
        expect(recipe[:attributes]).to have_key(:url)
        expect(recipe[:attributes]).to have_key(:country)
        expect(recipe[:attributes]).to have_key(:image)

        expect(recipe[:attributes][:title]).to be_a(String)
        expect(recipe[:attributes][:url]).to be_a(String)
        expect(recipe[:attributes][:country]).to be_a(String)
        expect(recipe[:attributes][:image]).to be_a(String)

        expect(recipe[:attributes]).to_not have_key(:summary)
        expect(recipe[:attributes]).to_not have_key(:uri)
        expect(recipe[:attributes]).to_not have_key(:capital)
        expect(recipe[:attributes]).to_not have_key(:video)
      end
    end

    it 'Shows a list of recipes for a random country if no search is inputted' do
      VCR.configure do |c|
        c.allow_http_connections_when_no_cassette = true
      end
      get '/api/v1/recipes'

      recipes = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      recipes[:data].each do |recipe|
        expect(recipe).to have_key(:id)
        expect(recipe).to have_key(:type)
        expect(recipe[:id]).to eq('null')
        expect(recipe[:type]).to eq('recipe')

        expect(recipe[:attributes]).to have_key(:title)
        expect(recipe[:attributes]).to have_key(:url)
        expect(recipe[:attributes]).to have_key(:country)
        expect(recipe[:attributes]).to have_key(:image)

        expect(recipe[:attributes][:title]).to be_a(String)
        expect(recipe[:attributes][:url]).to be_a(String)
        expect(recipe[:attributes][:country]).to be_a(String)
        expect(recipe[:attributes][:image]).to be_a(String)

        expect(recipe[:attributes]).to_not have_key(:summary)
        expect(recipe[:attributes]).to_not have_key(:uri)
        expect(recipe[:attributes]).to_not have_key(:capital)
        expect(recipe[:attributes]).to_not have_key(:video)
      end
      VCR.configure do |c|
        c.allow_http_connections_when_no_cassette = false
      end
    end
  end
end
