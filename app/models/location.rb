class Location < ApplicationRecord
  # attribute :id, :latitude, :longitude
  has_many :places, dependent: :destroy
  has_many :scores, dependent: :destroy

  validates :location_id, presence: true, uniqueness: true
  
  validate :validate_location_id
  validate :validate_latitude_range
  validate :validate_longitude_range
  
  before_validation :set_location

  def set_location
    self.latitude = point_format(latitude)
    self.longitude = point_format(longitude)
  end

  def validate_location_id
    return if /\A\d{1,2}.\d{1,6},\d{1,3}.\d{1,6}\z/.match(self.location_id)

    errors.add(:location_id, '不正な形式のIDです。in model')
  end

  def validate_latitude_range
    return if latitude >= -90 && latitude <= 90

    errors.add(:latitude, '範囲外の緯度です。')
  end

  def validate_longitude_range
    return if longitude >= -180 && longitude <= 179.999999

    errors.add(:longitude, '範囲外の経度です。')
  end
  
  def latitude
    @latitude ||= loc_to_f(self.location_id.split(',')[0])
  end
  
  
  def longitude
    @longitude ||= loc_to_f(self.location_id.split(',')[1])
  end

  def point_format point
    point.round(3)
  end

  def loc_to_f loc
    loc.gsub("'", ".").to_f
  end
end
