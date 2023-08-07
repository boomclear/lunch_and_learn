class CountriesFacade
  def service
    CountriesService.new
  end

  def list_of_countries
    list = service.country_list
    list.map do |country|
      country[:name][:common]
    end
  end

  def get_capital(country)
    capital = service.get_capital(country)
    capital.dig(0, :capital, 0)
  end
end