# frozen_string_literal: true

class Payment
  class Factory
    def initialize(organisation)
      @organisation = organisation
    end

    def from_import(payments_params)
      payments = payments_params.values.filter_map { |payment_params| Payment.new(payment_params) }
      payments = payments.select(&:applies)

      Payment.transaction do
        raise ActiveRecord::Rollback unless payments.all?(&:save)
      end

      payments
    end
  end
end
