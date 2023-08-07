require 'rails_helper'

RSpec.describe 'Register User' do
  describe 'Post request to register user' do
    ApiKey.destroy_all
    User.destroy_all
    it 'creates a user instance if a json payload is posted to the api', :vcr do
      user_params = {
        name: 'Odell',
        email: 'goodboy@ruffruff.com',
        password: 'treats4lyf',
        password_confirmation: 'treats4lyf'
      }
      headers = { 'CONTENT_TYPE' => 'application/json' }
      post '/api/v1/users', headers:, params: JSON.generate(user_params)

      model = User.last
      user = JSON.parse(response.body, symbolize_names: true)
      expect(response).to be_successful

      expect(model.name).to eq(user_params[:name])
      expect(model.email).to eq(user_params[:email])
      expect(user[:data]).to have_key(:id)
      expect(user[:data]).to have_key(:type)
      expect(user[:data][:type]).to eq('user')
      expect(user[:data]).to have_key(:attributes)
      expect(user[:data][:attributes]).to have_key(:name)
      expect(user[:data][:attributes]).to have_key(:email)
      expect(user[:data][:attributes]).to have_key(:api_key)
      expect(user[:data][:attributes][:name]).to eq('Odell')
      expect(user[:data][:attributes][:email]).to eq('goodboy@ruffruff.com')
    end
    it 'renders error when params are not up to standard' do
      user_params = {
        name: 'Odell',
        email: 'goodboy@ruffruff.com',
        password: 'treats4lyf',
        password_confirmation: ''
      }
      headers = { 'CONTENT_TYPE' => 'application/json' }
      post '/api/v1/users', headers:, params: JSON.generate(user_params)

      error = JSON.parse(response.body, symbolize_names: true)

      expect(error).to eq({ password_confirmation: ["doesn't match Password"] })
    end
  end
end
