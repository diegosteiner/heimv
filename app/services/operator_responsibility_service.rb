# frozen_string_literal: true

class OperatorResponsibilityService
  def initialize(booking)
    @booking = booking
  end

  def assign_all(*responsibilities)
    responsibilities.map { |responsibility| assign(responsibility) }
  end

  def assign(...)
    return existing(...) if existing(...).present?

    matching(...).first&.dup&.tap do |operator_responsibility|
      operator_responsibility.update(booking: @booking, home: @booking.home)
    end
  end

  def matching(responsibility)
    @booking.organisation.operator_responsibilities.ordered
            .where(responsibility: responsibility, home: [@booking.home, nil])
  end

  def existing(responsibility)
    @booking.operator_responsibilities.where(responsibility: responsibility).first
  end
end
