require 'rails_helper'

RSpec.describe 'Edamam Facade Test' do
  describe 'Edamam Facade methods' do
    it 'service method' do
      edamam = EdamamFacade.new.service

      expect(edamam).to be_a(EdamamService)
    end

    it 'creates recipe poro', :vcr do
      edamam = EdamamFacade.new.country_recipes('laos')

      expect(edamam).to be_a(Array)
      edamam.each do |e|
        expect(e).to be_a(Recipe)
      end
    end
  end
end
