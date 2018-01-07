class Occupancy < ApplicationRecord
  belongs_to :home
  belongs_to :subject, polymorphic: true, inverse_of: :occupancy

  validates :begins_at, :ends_at, :home, presence: true

  def to_s
    "#{I18n.l(begins_at)} - #{I18n.l(ends_at)}"
  end

  delegate :ref, to: :home
end
