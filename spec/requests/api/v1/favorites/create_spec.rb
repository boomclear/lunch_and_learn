require 'rails_helper'

RSpec.describe 'Register User' do
  describe 'Post request to register user' do
    it 'creates a user instance if a json payload is posted to the api', :vcr do
      user = User.create!(name: 'boom', email: 'boom@yahoo.com', password: 'test')
      api_key = user.api_keys.create!(token: SecureRandom.hex)

      expect(user.favorites.count).to eq(0)
      favorite_params = {
        api_key: api_key.token,
        country: 'thailand',
        recipe_link: 'https://www.tastingtable.com/.....',
        recipe_title: 'Crab Fried Rice (Khaao Pad Bpu)'
      }

      headers = { 'CONTENT_TYPE' => 'application/json' }
      post '/api/v1/favorites', headers:, params: JSON.generate(favorite_params)

      json_response = JSON.parse(response.body, symbolize_names: true)
      expect(response).to be_successful

      expect(json_response).to be_a(Hash)
      expect(json_response).to have_key(:success)
      expect(json_response[:success]).to eq('Favorite added successfully')
      expect(user.favorites.count).to eq(1)
    end

    it 'renders error when params are not up to standard' do
      favorite_params = {
        api_key: 'lmnop',
        country: 'thailand',
        recipe_link: 'https://www.tastingtable.com/.....',
        recipe_title: 'Crab Fried Rice (Khaao Pad Bpu)'
      }
      headers = { 'CONTENT_TYPE' => 'application/json' }
      post '/api/v1/favorites', headers:, params: JSON.generate(favorite_params)

      error = JSON.parse(response.body, symbolize_names: true)

      expect(error).to eq('Invalid API Key')
    end
    it 'renders error when params are not up to standard' do

      user = User.create!(name: 'boom', email: 'boom@yahoo.com', password: 'test')
      api_key = user.api_keys.create!(token: SecureRandom.hex)

      favorite_params = {
        api_key: api_key.token,
        recipe_link: 'https://www.tastingtable.com/.....',
        recipe_title: 'Crab Fried Rice (Khaao Pad Bpu)'
      }
      headers = { 'CONTENT_TYPE' => 'application/json' }
      post '/api/v1/favorites', headers:, params: JSON.generate(favorite_params)

      error = JSON.parse(response.body, symbolize_names: true)

      expect(error).to eq({country: ["can't be blank"]})
    end
  end
end
