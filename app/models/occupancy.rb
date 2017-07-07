class Occupancy < ApplicationRecord
  belongs_to :home

  validates :begins_at, :ends_at, :home, presence: true

  def to_s
    "#{I18n.l(begins_at)} - #{I18n.l(ends_at)} (#{ref})"
  end

  def ref
    home.ref
  end
end
