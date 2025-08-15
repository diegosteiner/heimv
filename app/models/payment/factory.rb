# frozen_string_literal: true

class Payment
  class Factory
    def initialize(organisation)
      @organisation = organisation
    end

    def from_import(payments_params)
      payments = payments_params.values.filter_map { build(it) }
      payments = payments.select(&:applies)

      Payment.transaction do
        raise ActiveRecord::Rollback unless payments.all?(&:save)
      end

      payments
    end

    def build(attributes = {})
      Payment.new(attributes).tap do |payment|
        payment.organisation = @organisation
        payment.paid_at ||= Time.zone.now
        payment.amount ||= payment.invoice&.amount_open
      end
    end
  end
end
