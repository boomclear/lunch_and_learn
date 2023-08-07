class Api::V1::SessionsController < ApplicationController
  def create
    if User.find_by(email: params[:email])
      user = User.find_by(email: params[:email])
      if user.authenticate(params[:password])
        render json: UserSerializer.new(user)
      else
        render json: JSON.generate('Invalid Credentials'), status: :bad_request
      end
    else
      render json: JSON.generate('Invalid Credentials'), status: :bad_request
    end
  end
end
