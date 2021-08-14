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
      
      # 不正なLocationIDでないかチェック
      # 緯度：-90~90
      # 経度：-180~179.999999
      return render json: {status: 400} if !params[:id].match('_')
      location_info = params[:id].split('_')
      latitude = location_info[0].gsub("'", ".").to_f
      return render json: {status: 400} if latitude < -90 || latitude > 90
      longitude = location_info[1].gsub("'", ".").to_f
      return render json: {status: 400} if longitude < -180 || longitude > 179.999999
      loc = "#{latitude},#{longitude}"

      resp = conn.get '/maps/api/place/nearbysearch/json', { location: loc, radius: 1500, type: 'restaurant', key: 'AIzaSyBLLxwnSdKnQFDAapcGqMjBhbxz0yUknAg' }

      render json: { response: JSON.parse(resp.body) }
    end
  end
end