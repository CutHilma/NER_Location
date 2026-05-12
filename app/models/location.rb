class Location < ApplicationRecord
  validates :lokasi, presence: true, uniqueness: true
end
