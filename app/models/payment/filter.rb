# frozen_string_literal: true

class Payment
  class Filter < ApplicationFilter
    attribute :ref
    attribute :paid_at_after, :date
    attribute :paid_at_before, :date

    filter :paid do |payments|
      next payments unless paid_at_after || paid_at_before

      paid_at = Payment.arel_table[:paid_at]
      next payments.where(paid_at.gteq(paid_at_after)) if paid_at_after && !paid_at_before
      next payments.where(paid_at.lteq(paid_at_before)) if !paid_at_after && paid_at_before

      next payments.where(paid_at.between(paid_at_after..paid_at_before))
    end

    filter :ref do |payments|
      payments.where(Payment.arel_table[:ref].matches("%#{ref}%")) if ref.present?
    end
  end
end
