require 'rails_helper'

RSpec.describe 'login in through api' do
  describe 'post login method' do
    it 'returns successful response if user posts correct credentials' do
      user = User.create!(name: 'boom', password: 'test', password_confirmation: 'test', email: 'boom@gmail.com')
      user.api_keys.create!(token: SecureRandom.hex)
      user_params = {
        email: 'boom@gmail.com',
        password: 'test'
      }
      headers = { 'CONTENT_TYPE' => 'application/json' }
      post '/api/v1/sessions', headers:, params: JSON.generate(user_params)

      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(json_response).to be_a(Hash)
      expect(json_response[:data]).to have_key(:id)
      expect(json_response[:data]).to have_key(:type)
      expect(json_response[:data][:type]).to eq('user')
      expect(json_response[:data]).to have_key(:attributes)
      expect(json_response[:data][:attributes]).to have_key(:name)
      expect(json_response[:data][:attributes]).to have_key(:email)
      expect(json_response[:data][:attributes]).to have_key(:api_key)
      expect(json_response[:data][:attributes][:name]).to eq('boom')
      expect(json_response[:data][:attributes][:email]).to eq('boom@gmail.com')
    end
    it 'returns 400 response if user posts incorrect credentials' do
      user = User.create!(name: 'boom', password: 'test', password_confirmation: 'test', email: 'boom@gmail.com')
      user.api_keys.create!(token: SecureRandom.hex)
      user_params = {
        email: 'boom@gmail.com',
        password: 'badpassword'
      }
      headers = { 'CONTENT_TYPE' => 'application/json' }
      post '/api/v1/sessions', headers:, params: JSON.generate(user_params)

      json_response = JSON.parse(response.body, symbolize_names: true)
      
      expect(json_response).to eq("Invalid Credentials")
    end
    
    it 'returns 400 response if user posts incorrect credentials' do
      user = User.create!(name: 'boom', password: 'test', password_confirmation: 'test', email: 'boom@gmail.com')
      user.api_keys.create!(token: SecureRandom.hex)
      user_params = {
        email: 'a;lsdjfa;lsdjf@gmail.com',
        password: 'badpassword'
      }
      headers = { 'CONTENT_TYPE' => 'application/json' }
      post '/api/v1/sessions', headers:, params: JSON.generate(user_params)

      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(json_response).to eq("Invalid Credentials")
    end
  end
end
