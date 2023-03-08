module BookingValidator
  class PublicCreate < ActiveModel::Validator
    def validate(booking)
      booking.instance_exec do 
        errors.add(:base, :invalid) unless occupiables.present?
        errors.add(:accept_conditions, :accepted) unless accept_conditions.present?
        errors.add(:base, :invalid) unless occupancies.all? { |occupancy| validate_occupancy(occupancy) }
      end
    end

    private

    def validate_occupancy(occupancy)
      occupancy.instance_exec do
        validate
        next errors.add(:base, :conflicting) if conflicting(0).any?

        margin = organisation.settings.booking_margin
        next if margin.zero? || conflicting(margin).none?

        errors.add(:base, :margin_too_small, margin: margin&.in_minutes&.to_i)
        valid?
      end
    end
  end

  class PublicUpdate < PublicCreate
    def validate(booking)
      super
      booking.instance_exec do 
        errors.add(:approximate_headcount, :blank) unless approximate_headcount.present?
        errors.add(:purpose_description, :blank) unless purpose_description.present?
        errors.add(:committed_request, :blank) unless [true, false].include?(committed_request)
        errors.add(:category, :blank) unless category.present?
      end
    end
  end
end

