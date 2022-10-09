# frozen_string_literal: true

class UsageAggregator
  attr_reader :booking

  def initialize(booking)
    @booking = booking
  end

  def costs_total
    return @costs_total if @costs_total

    deposits = Invoices::Deposit.of(booking).kept
    invoices = Invoices::Invoice.of(booking).kept

    @costs_total = { deposit: deposits.sum(:amount), total: invoices.sum(:amount) }
  end

  def costs_per_person_per_night
    costs_total
  end
end
