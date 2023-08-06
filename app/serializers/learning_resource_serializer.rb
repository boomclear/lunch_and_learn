class LearningResourceSerializer
  include JSONAPI::Serializer
  attribute :country

  attribute :video do |object|
    {title: object.video_title, youtube_video_id: object.video_id}
  end

  attribute :images do |object|
    object.images_formatted
  end
end
