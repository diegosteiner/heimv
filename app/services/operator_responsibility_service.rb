# frozen_string_literal: true

class OperatorResponsibilityService
  def initialize(booking)
    @booking = booking
  end

  def assign(*responsibilities)
    responsibilities.map do |responsibility|
      next @booking.operator_for(responsibility) if @booking.operator_for(responsibility).present?

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
