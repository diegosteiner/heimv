class Payment
  class Filter < ApplicationFilter
    attribute :ref
    attribute :paid_at_after, :date
    attribute :paid_at_before, :date
    multi_param_attribute paid_at_before: Date, paid_at_after: Date

    filter do |payments|
      next payments unless paid_at_after || paid_at_before
      next payments.where(Payment.arel_table[:paid_at].gteq(paid_at_after)) if paid_at_after && !paid_at_before
      next payments.where(Payment.arel_table[:paid_at].lteq(paid_at_before)) if !paid_at_after && paid_at_before

      next payments.where(Payment.arel_table[:paid_at].between(paid_at_after..paid_at_before))
    end

    filter do |payments|
      next payments if ref.blank?

      payments.where(Payment.arel_table[:ref].matches("%#{ref}%"))
    end
  end
end
