class CountriesService
  def conn
    Faraday.new(url: 'https://restcountries.com/v3.1/')
  end

  def get_url(url)
    response = conn.get(url)
    JSON.parse(response.body, symbolize_names: true)
  end

  def country_list
    get_url("all?fields=name")
  end
end

