# frozen_string_literal: true

class Payment
  class Filter < ApplicationFilter
    SORTERS = {
      '-paid_at' => { paid_at: :DESC },
      'paid_at' => { paid_at: :ASC }
    }.freeze

    attribute :ref
    attribute :paid_at_after, :datetime
    attribute :paid_at_before, :datetime
    attribute :sort

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

    filter :sort do |payments|
      sort_by = SORTERS[sort]
      payments.reorder(sort_by) if sort_by.present?
    end
  end
end
