require 'rails_helper'

RSpec.describe 'Recipes Index' do
  describe 'Search for Recipes' do
    it 'Shows a list of recipes for country searched for' do
      get "/api/v1/recipes?country=thailand"

      recipes = JSON.parse(response.body, symbolize_names: true)

      expect(recipes[:data].count).to eq(20)

      expect(response).to be_successful

      recipes[:data].each do |recipe|
        expect(recipe).to have_key(:id)

        expect(recipe[:attributes]).to have_key(:title)
        expect(recipe[:attributes]).to have_key(:url)
        expect(recipe[:attributes]).to have_key(:country)
        expect(recipe[:attributes]).to have_key(:image)
      end
    end
  end
end
