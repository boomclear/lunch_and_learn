require "rails_helper"

RSpec.describe "Youtube Service Spec" do 
  describe "Youtube Service Test" do 
    it "returns a Mr. History Video", :vcr do 
      video = YoutubeService.new.country_video("laos")

      expect(video).to be_a(Hash)
      expect(video[:items][0][:snippet][:channelId]).to eq("UCluQ5yInbeAkkeCndNnUhpw")
      expect(video[:items][0][:snippet][:title]).to eq("A Super Quick History of Laos")
      expect(video[:items][0][:id][:videoId]).to eq("uw8hjVqxMXw")
    end
  end
end