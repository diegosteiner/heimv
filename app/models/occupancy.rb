class Occupancy < ApplicationRecord
  belongs_to :home

  validates :begins_at, :ends_at, :home, presence: true
end
