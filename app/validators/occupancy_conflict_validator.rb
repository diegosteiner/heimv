# frozen_string_literal: true

class OccupancyConflictValidator < ActiveModel::Validator
  def validate(record, assuming: nil)
    return validate(record.booking, assuming:) if record.is_a?(AgentBooking)
    return record.occupancies.all? { validate(it, assuming:) } if record.is_a?(Booking)
    return if record.ignore_conflicting || record.validation_context == :ignore_conflicting

    return true unless record.conflicting?(assuming:)

    record.errors.add(:base, :occupancy_conflict, occupiable: record.occupiable&.name)
    false
  end
end
