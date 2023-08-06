class YoutubeService
  def conn
    Faraday.new(url: 'https://youtube.googleapis.com/youtube/v3/')
  end

  def get_url(url)
    response = conn.get(url)
    JSON.parse(response.body, symbolize_names: true)
  end

  def country_video(country)
    get_url("search?part=snippet&channelId=UCluQ5yInbeAkkeCndNnUhpw&q=#{country}&key=#{ENV['google_api']}")
  end
end
