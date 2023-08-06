require 'rails_helper'

RSpec.describe 'Edamam Service Spec' do
  describe 'Edamam Service Test' do
    it 'returns recipes for specific country', :vcr do
      recipes = EdamamService.new.country_recipes('laos')

      expect(recipes).to be_a(Hash)
      expect(recipes[:hits]).to be_a(Array)
      recipes[:hits].each do |recipe|
        expect(recipe).to have_key(:recipe)
      end
    end
  end
end
