class Api::V1::RecipesController < ApplicationController 

  def index
    recipes = EdamamFacade.new.country_recipes(params[:country])
    render json: RecipeSerializer.new(recipes)
  end
end