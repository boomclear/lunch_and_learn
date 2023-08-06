class Api::V1::RecipesController < ApplicationController
  def index
    if params[:country]
      recipes = EdamamFacade.new.country_recipes(params[:country])
    else
      country = CountriesFacade.new.list_of_countries[rand(250)]
      recipes = EdamamFacade.new.country_recipes(country)
    end
    render json: RecipeSerializer.new(recipes)
  end
end
