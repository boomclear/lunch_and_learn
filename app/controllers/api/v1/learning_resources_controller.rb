class Api::V1::LearningResourcesController < ApplicationController
  def index
    learning_resource = LearningResourcesFacade.new.learning_resource(params[:country])
    render json: LearningResourceSerializer.new(learning_resource)
  end

  private

  def country_params
    params.permit(:country)
  end
end
