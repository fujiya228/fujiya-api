class Score < ApplicationRecord
  belongs_to :location

  before_save :calc_score
  validates :score_type, uniqueness: { scope: :location_id}

  def calc_score
    self.score_type = self.score_type&.upcase
    self.score_type = :V1 unless ::PLACE_INFO[self.score_type.intern]
    place_info_list = ::PLACE_INFO[self.score_type.intern]
    place_type_list = place_info_list.pluck(:type)
    places = Hash[*location.places.pluck(:place_type, :count).flatten].filter{|key| place_type_list.include?(key)}

    point = 0
    
    place_info_list.each do |info|
      point += places[info[:type]] * info[:score]
      point += 10 * info[:score] if places[info[:type]] == 60 
    end
    self.point = point
  end
end
