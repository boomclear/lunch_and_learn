require "rails_helper"

RSpec.describe "Countries Service Spec" do 
  describe "Countries Service Test" do 
    it "returns a list of countries", :vcr do 
      country = CountriesService.new.country_list

      expect(country).to be_a(Array)
      expect(country.count).to eq(250)
    end
  end
end