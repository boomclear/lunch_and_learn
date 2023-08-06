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

end