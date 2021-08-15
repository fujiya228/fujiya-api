module Api::V1
  class LocationScoresController < ApplicationController
    before_action :validate_location_id
    
    def show
      uri = "https://maps.googleapis.com"
      conn = Faraday::Connection.new(url: uri) do |builder|
        builder.adapter Faraday.default_adapter
        builder.request :url_encoded 
        builder.response :logger # ログを出す
        builder.headers['Content-Type'] = 'application/json' # ヘッダー指定
      end

      location = Location.find_by(location_id: location_id)
      if location
        render json: { location: { id: location.id, location_id: location.location_id} }, status: :ok
      else
        location = Location.create(location_id: location_id)
        if location.valid?
          resp = conn.get '/maps/api/place/nearbysearch/json', { location: location_id, radius: 1500, type: 'restaurant', key: 'AIzaSyBLLxwnSdKnQFDAapcGqMjBhbxz0yUknAg' }
          render json: { response: JSON.parse(resp.body) }
        else
          render json: { messages: location.errors.full_messages }, status: :bad_request
        end
      end
    end

    def validate_location_id
      return if /\A\d{1,2}'*\d{0,6}_\d{1,3}'*\d{0,6}\z/.match(params[:id])

      render json: {message: '不正な形式のIDです。'}, status: :bad_request
    end

    def location_id
      @location_id ||= point_format(latitude).to_s + ',' + point_format(longitude).to_s
    end

    def latitude
      @latitude ||= loc_to_f(params[:id].split('_')[0])
    end
    
    
    def longitude
      @longitude ||= loc_to_f(params[:id].split('_')[1])
    end

    def point_format point
      point.round(6)
    end

    def loc_to_f loc
      loc.gsub("'", ".").to_f
    end
  end
end