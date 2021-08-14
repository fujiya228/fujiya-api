module Api::V1
  class LocationScoresController < ApplicationController
    def show
      uri = "https://maps.googleapis.com"
      conn = Faraday::Connection.new(url: uri) do |builder|
        builder.adapter Faraday.default_adapter
        builder.request :url_encoded 
        builder.response :logger # ログを出す
        builder.headers['Content-Type'] = 'application/json' # ヘッダー指定
      end
      resp = conn.get '/maps/api/place/nearbysearch/json', { location: '35.721183,139.773143', radius: 1500, type: 'restaurant', key: 'AIzaSyBLLxwnSdKnQFDAapcGqMjBhbxz0yUknAg' }
      render json: { response: JSON.parse(resp.body) }
    end
  end
end