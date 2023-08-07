class Api::V1::AirQualityController < ApplicationController
  def index
    capital = CountriesFacade.new.get_capital(params[:country])
  end
end