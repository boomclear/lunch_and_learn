class EdamamFacade
  def service 
    EdamamService.new
  end

  def country_recipes(country)
    request = service.country_recipes(country)
    request[:hits].map do |hit|
      Recipe.new(country, hit[:recipe])
    end
  end

end