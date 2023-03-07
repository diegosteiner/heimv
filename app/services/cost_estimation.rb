# frozen_string_literal: true

class CostEstimation
  attr_reader :booking, :fixcosts

  def initialize(booking, fixcosts: 0)
    @booking = booking
    @fixcosts = fixcosts
  end

  def used
    booking.usages.sum(&:price)
  end

  def total
    invoices = Invoices::Invoice.of(booking).kept
    return if invoices.blank?

    @total ||= deposit + invoices.sum(:amount)
  end

  def deposit
    Invoices::Deposit.of(booking).kept.sum(:amount) || 0
  end

  def per_day
    return if total.nil?

    [total - fixcosts, 0].max / days
  end

  def per_person
    return unless booking.approximate_headcount.to_i.positive? && total.present?

    [total - fixcosts, 0].max / booking.approximate_headcount
  end

  def days
    (booking.nights || 0) + 1
  end

  def person_days
    days * (booking.approximate_headcount || 1)
  end

  def per_person_per_day
    return if total.nil?

    total / [person_days, 1].max
  end

  def reference_bookings
    Booking::Filter.new(previous_booking_states: %i[completed], ends_at_after: 1.year.ago,
                        homes: booking.home_id, categories: booking.booking_category_id)
                   .apply(booking.organisation.bookings.where.not(approximate_headcount: nil))
  end

  def projection
    mean_costs = self.class.mean_costs_per_person_per_day(reference_bookings, fixcosts: fixcosts)
    fixcosts + ((mean_costs || 0) * person_days)
  end

  def projection_difference
    return nil unless total

    projection - total
  end

  class << self
    def reference_bookings(organisation)
      Booking::Filter.new(previous_booking_states: %i[completed], ends_at_after: 2.years.ago)
                     .apply(organisation.bookings)
    end

    def estimations(bookings, fixcosts: 0)
      bookings.index_with { |booking| new(booking, fixcosts: fixcosts) }
    end

    def projection(bookings, fixcosts: 0)
      errors = []
      samples = estimations(bookings, fixcosts: fixcosts).transform_values do |cost_estimation|
        next cost_estimation.projection if cost_estimation.total.blank?

        errors << cost_estimation.projection_difference
        cost_estimation.total
      end
      { total: samples.values.sum, errors: errors, samples: samples }
    end

    def mean_costs_per_person_per_day(bookings, fixcosts: 0)
      samples = bookings.map { |booking| new(booking, fixcosts: fixcosts).per_person_per_day }

      # cut off 10% on each end and take the mean of it
      samples.sort.slice(samples.count * 0.1, samples.count * 0.8)[samples.count * 0.4]
    end
  end
end
