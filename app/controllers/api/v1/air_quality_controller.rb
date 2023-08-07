class Api::V1::AirQualityController < ApplicationController
  def index
    capital = CountriesFacade.new.get_capital(params[:country])
    data = NinjaFacade.new.city_aqi(capital)
    render json: data.formatted
  end
end
