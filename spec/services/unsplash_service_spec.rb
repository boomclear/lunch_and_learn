require "rails_helper"

RSpec.describe "Unsplash Service Spec" do 
  describe "Unsplash Service Test" do 
    it "returns 10 images", :vcr do 
      images = UnsplashService.new.country_images("laos")

      expect(images).to be_a(Hash)
      expect(images[:results].count).to eq(10)
    end
  end
end