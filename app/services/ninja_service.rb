class NinjaService
  def conn
    Faraday.new(url: 'https://api.api-ninjas.com/v1/')
  end

  def get_url(url)
    response = conn.get(url) do |request|
      request.headers['X-Api-Key'] = ENV['ninja_api']
    end
    JSON.parse(response.body, symbolize_names: true)
  end

  def city_aqi(city)
    get_url("airquality?city=#{city}")
  end
end
