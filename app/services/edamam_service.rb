class EdamamService
  def conn
    Faraday.new(url: 'https://api.edamam.com/api/recipes/v2')
  end

  def get_url(url)
    response = conn.get(url)
    JSON.parse(response.body, symbolize_names: true)
  end

  def country_recipes
    get_url('?type=public&q=thailand&app_id=00177db4&app_key=%20f4298302c7c122f63d642b9b18413f3d')
  end
end
