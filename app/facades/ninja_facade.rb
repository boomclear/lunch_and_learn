class NinjaFacade
  def service
    NinjaService.new
  end

  def city_aqi(city)
    request = service.city_aqi(city)
    AirQuality.new(city, request)
  end
end
