# frozen_string_literal: true

class KeySequence < ApplicationRecord
  belongs_to :organisation, inverse_of: :key_sequences

  validates :key, presence: true, uniqueness: { scope: %i[organisation_id year] }

  scope :key, ->(key, year: nil) { find_or_create_by(key:, year: year.is_a?(TrueClass) ? Time.zone.today.year : year) }

  def lease!
    increment!(:value).value # rubocop:disable Rails/SkipsModelValidations
  end
end
