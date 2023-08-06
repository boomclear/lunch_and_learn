class LearningResource
  attr_reader :country, :video_id, :video_title, :id
  def initialize(country, video, images)
    @id = "null"
    @country = country
    @video_id = video[:id][:videoId]
    @video_title = video[:snippet][:title]
    @images_unformatted = images
  end 

  def images_formatted
    formatted_array = []

    @images_unformatted.each do |image|
      formatted_array.push({alt_tag: image[:description], url: image[:urls][:raw]})
    end

    formatted_array
  end
end