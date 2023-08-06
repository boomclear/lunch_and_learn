require 'rails_helper'

RSpec.describe 'Learning Resources Facade Test' do
  describe 'Learning Resources Facade Methods test' do
    it 'youtube service' do
      lr = LearningResourcesFacade.new.youtube_service

      expect(lr).to be_a(YoutubeService)
    end

    it 'unsplash service' do
      lr = LearningResourcesFacade.new.unsplash_service

      expect(lr).to be_a(UnsplashService)
    end

    it 'creates a learning resource poro', :vcr do
      lr = LearningResourcesFacade.new.learning_resource('laos')

      expect(lr).to be_a(LearningResource)
    end
  end
end
