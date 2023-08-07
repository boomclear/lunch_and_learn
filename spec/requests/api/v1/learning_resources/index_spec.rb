require 'rails_helper'

RSpec.describe 'Learning Resouces Page' do
  describe 'Learning Resources Page has content' do
    it 'Has video and image content for the searched country' do
      VCR.use_cassette('spec/fixtures/vcr_cassettes/Learning_Resources_Page_has_content/youtube.yml') do
        get '/api/v1/learning_resources?country=laos'

        resources = JSON.parse(response.body, symbolize_names: true)
        expect(response).to be_successful
        expect(resources[:data]).to have_key(:id)
        expect(resources[:data]).to have_key(:type)
        expect(resources[:data][:id]).to eq('null')
        expect(resources[:data][:type]).to eq('learning_resource')
        expect(resources[:data][:id]).to be_a(String)
        expect(resources[:data][:type]).to be_a(String)

        expect(resources[:data][:attributes]).to have_key(:country)
        expect(resources[:data][:attributes]).to have_key(:video)
        expect(resources[:data][:attributes][:video]).to have_key(:title)
        expect(resources[:data][:attributes][:video]).to have_key(:youtube_video_id)
        expect(resources[:data][:attributes]).to have_key(:images)
        expect(resources[:data][:attributes][:images][0]).to have_key(:alt_tag)
        expect(resources[:data][:attributes][:images][0]).to have_key(:url)

        expect(resources[:data][:attributes]).to be_a(Hash)
        expect(resources[:data][:attributes][:country]).to be_a(String)
        expect(resources[:data][:attributes][:video]).to be_a(Hash)
        expect(resources[:data][:attributes][:video][:title]).to be_a(String)
        expect(resources[:data][:attributes][:video][:youtube_video_id]).to be_a(String)
        expect(resources[:data][:attributes][:images]).to be_a(Array)
        expect(resources[:data][:attributes][:images][0][:alt_tag]).to be_a(String)
        expect(resources[:data][:attributes][:images][0][:url]).to be_a(String)

        expect(resources[:data][:attributes]).to_not have_key(:capital)
        expect(resources[:data][:attributes]).to_not have_key(:youtube_url)
        expect(resources[:data][:attributes][:video]).to_not have_key(:description)
        expect(resources[:data][:attributes][:video]).to_not have_key(:channel_id)
        expect(resources[:data][:attributes]).to_not have_key(:unsplash_url)
        expect(resources[:data][:attributes][:images][0]).to_not have_key(:alt_description)
        expect(resources[:data][:attributes][:images][0]).to_not have_key(:raw)
      end
    end
  end
end
