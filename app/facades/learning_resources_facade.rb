class LearningResourcesFacade
  def youtube_service
    YoutubeService.new
  end

  def unsplash_service
    UnsplashService.new
  end

  def learning_resource(country)
    youtube_request = youtube_service.country_video(country)
    unsplash_request = unsplash_service.country_images(country)
    LearningResource.new(country, youtube_request.dig(:items, 0), unsplash_request[:results])
  end
end
