require 'rails_helper'

RSpec.describe 'Register User' do
  describe 'Post request to register user' do
    it 'creates a user instance if a json payload is posted to the api', :vcr do
      user = User.create!(name: 'broom', email: 'broom@yahoo.com', password: 'test')
      api_key = user.api_keys.create!(token: SecureRandom.hex)
      user.favorites.create!(country: 'laos', recipe_link: 'www.google.com', recipe_title: 'Buns')
      user.favorites.create!(country: 'vietnam', recipe_link: 'www.yahoo.com', recipe_title: 'Burger    ')

      get "/api/v1/favorites?api_key=#{api_key.token}"

      favorites = JSON.parse(response.body, symbolize_names: true)

      expect(favorites).to be_a(Hash)
      favorites[:data].each do |favorite|
        expect(favorite).to have_key(:id)
        expect(favorite).to have_key(:type)
        expect(favorite[:type]).to eq('favorite')

        expect(favorite[:attributes]).to have_key(:recipe_link)
        expect(favorite[:attributes]).to have_key(:recipe_title)
        expect(favorite[:attributes]).to have_key(:country)
        expect(favorite[:attributes]).to have_key(:created_at)

        expect(favorite[:attributes][:recipe_link]).to be_a(String)
        expect(favorite[:attributes][:recipe_title]).to be_a(String)
        expect(favorite[:attributes][:country]).to be_a(String)
        expect(favorite[:attributes][:created_at]).to be_a(String)
      end
    end
    it 'renders error when api key invalid' do
      get "/api/v1/favorites?api_key=test"

      error = JSON.parse(response.body, symbolize_names: true)

      expect(error).to eq('Invalid API Key')
    end
  end
end
