module Api::V1
  class LocationScoresController < ApplicationController
    before_action :validate_location_id
    before_action :set_score_type
    before_action :set_location
    
    def show
      place_type_list = place_info_list.pluck(:type)
      location_all_place_type_list = @location.places.pluck(:place_type)
      
      # place_type_listに含まれていないものがある場合に新規作成
      not_include_place_type_list = place_info_list.filter{ |info| !location_all_place_type_list.include?(info[:type]) }
      create_places(not_include_place_type_list) if not_include_place_type_list.present?
      
      # 更新が必要なplaceがある場合に更新
      need_update_place_list = @location.places.filter{ |place| place.updated_at + 6.month < current_time && place_type_list.include?(place.place_type) }
      update_places(need_update_place_list) if need_update_place_list.present?
      
      score = @location.scores.find_or_create_by(score_type: @score_type)
      
      render json: {
        location: {
          location_id: @location.location_id,
          latitude: @location.latitude,
          longitude: @location.longitude
        },
        places: Hash[*@location.places.pluck(:place_type, :count).flatten].filter{|key| place_type_list.include?(key)},
        score: score.point
      }, status: :ok
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
      point.round(3)
    end

    def loc_to_f loc
      loc.gsub("'", ".").to_f
    end

    def place_info_list
      @place_info_list ||= ::PLACE_INFO[@score_type]
    end

    def current_time
      @current_time ||= DateTime.current
    end

    def set_score_type
      @score_type = params[:score_type]&.upcase&.intern
      @score_type = :V1 unless ::PLACE_INFO[@score_type]
    end

    def set_location
      @location = Location.find_by(location_id: location_id)
      if @location.blank?
        @location = Location.create(location_id: location_id)
        if @location.valid?
          create_places(place_info_list)
          @location.scores.create({score_type: @score_type})
        else
          render json: { messages: @location.errors.full_messages }, status: :bad_request
        end
      end
    end

    def create_places info_list
      info_list.each do |info|
        count = get_place_count(info[:type])
        @location.places.create({place_type: info[:type], count: count })
      end
    end

    def update_places place_list
      place_list.each do |place|
        count = get_place_count(place.place_type)
        place.update({ count: count, updated_at: current_time })
      end
    end
    
    def get_place_count keyword
      count = 0
      # TODO:エラーハンドリングしてない。追加する
      res = conn.get '/maps/api/place/nearbysearch/json', { location: location_id, radius: 500, keyword: keyword, key: ENV['GOOGLE_PLACES_API_KEY'] }
      data = JSON.parse(res.body)
      if res.status != 200
        raise RuntimeError
      end
      count = data["results"].count
      while data["next_page_token"] do
        sleep 2 # リクエスト多いとINVALID_REQUEST返された
        res = conn.get '/maps/api/place/nearbysearch/json', { pagetoken: data["next_page_token"], key: ENV['GOOGLE_PLACES_API_KEY'] }
        data = JSON.parse(res.body)
        count += data["results"].count
        break if count > 40
      end
      
      count
    end
    
    def conn
      uri = "https://maps.googleapis.com"
      @conn ||= Faraday::Connection.new(url: uri) do |builder|
        builder.adapter Faraday.default_adapter
        builder.request :url_encoded 
        builder.response :logger # ログを出す
        builder.headers['Content-Type'] = 'application/json' # ヘッダー指定
      end
    end

    rescue_from StandardError do |e|
      render json: {
        errors: [
          server: 'internal server error'
        ],
        status: 500
      }, status: :internal_server_error
    end
  end
end