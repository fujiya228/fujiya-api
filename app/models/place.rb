class Place < ApplicationRecord
  belongs_to :location

  validates :place_type, uniqueness: { scope: :location_id}
end
