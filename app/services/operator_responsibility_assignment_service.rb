# frozen_string_literal: true

class OperatorResponsibilityAssignmentService
  def initialize(booking)
    @booking = booking
  end

  def assign(*responsibilities)
    responsibilities.map do |responsibility|
      existing_operator = @booking.operators_for(responsibility).first
      next existing_operator if existing_operator.present?

      matching(responsibility).first&.dup&.tap do |operator_responsibility|
        operator_responsibility.update(booking: @booking, home: @booking.home)
      end
    end
  end

  def matching(responsibility)
    @booking.organisation.operator_responsibilities.ordered
            .where(responsibility: responsibility, home: [@booking.home, nil], booking: nil)
  end
end
