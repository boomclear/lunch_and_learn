class EdamamService
  def conn
    Faraday.new(url: 'https://api.edamam.com/api/recipes/v2')
  end

  def get_url(url)
    response = conn.get(url)
    JSON.parse(response.body, symbolize_names: true)
  end

  def country_recipes(country)
    get_url("?type=public&q=#{country}&app_id=#{ENV['edamam_id']}&app_key=%#{ENV['edamam_key']}")
  end
end
