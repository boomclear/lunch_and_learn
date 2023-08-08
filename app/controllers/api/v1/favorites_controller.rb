class Api::V1::FavoritesController < ApplicationController
  def create
    if api = ApiKey.find_by(token: params[:api_key])
      favorite = api.user.favorites.new(country: params[:country], recipe_link: params[:recipe_link],
                                        recipe_title: params[:recipe_title])
      if favorite.save
        render json: JSON.generate({ success: 'Favorite added successfully' }), status: :created
      else
        render json: favorite.errors, status: :unprocessable_entity
      end
    else
      render json: JSON.generate('Invalid API Key'), status: :unauthorized
    end
  end

  def index
    if api = ApiKey.find_by(token: params[:api_key])
      favorites = api.user.favorites
      render json: FavoritesSerializer.new(favorites)
    else
      render json: JSON.generate('Invalid API Key'), status: :unauthorized
    end
  end

  private

  def favorites_params
    params.permit(:api_key, :country, :recipe_link, :recipe_title)
  end
end
