class UnsplashService
  def conn
    Faraday.new(url: 'https://api.unsplash.com')
  end

  def get_url(url)
    response = conn.get(url)
    JSON.parse(response.body, symbolize_names: true)
  end

  def country_images(country)
    get_url("/search/photos?query=#{country}&client_id=#{ENV['unsplash_key']}")
  end
end