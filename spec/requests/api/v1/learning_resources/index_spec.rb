require 'rails_helper'

RSpec.describe 'Learning Resouces Page' do
  describe 'Learning Resources Page has content' do
    it 'Has video and image content for the searched country' do
      VCR.use_cassette('spec/fixtures/vcr_cassettes/Learning_Resources_Page_has_content/youtube.yml') do
        get '/api/v1/learning_resources?country=laos'

        resources = JSON.parse(response.body, symbolize_names: true)
        expect(response).to be_successful
        expect(resources[:data]).to have_key(:id)

        expect(resources[:data][:attributes]).to have_key(:country)
        expect(resources[:data][:attributes]).to have_key(:video)
        expect(resources[:data][:attributes][:video]).to have_key(:title)
        expect(resources[:data][:attributes][:video]).to have_key(:youtube_video_id)
        expect(resources[:data][:attributes]).to have_key(:images)
        expect(resources[:data][:attributes][:images][0]).to have_key(:alt_tag)
        expect(resources[:data][:attributes][:images][0]).to have_key(:url)
      end
    end
  end
end
