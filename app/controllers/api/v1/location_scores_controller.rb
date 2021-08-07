module Api::V1
  class LocationScoresController < ApplicationController
    def show
      render json: { message: "test" }
    end
  end
end