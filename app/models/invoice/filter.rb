# frozen_string_literal: true

class Invoice
  class Filter < ApplicationFilter
    attribute :issued_at_after, :datetime
    attribute :issued_at_before, :datetime
    attribute :payable_until_after, :datetime
    attribute :payable_until_before, :datetime
    attribute :invoice_types, default: -> { [] }
    attribute :statuses
    attribute :ref

    filter :issued_at do |invoices|
      next unless issued_at_before.present? || issued_at_after.present?

      invoices.where(Invoice.arel_table[:issued_at].between(issued_at_after..issued_at_before))
    end

    filter :payable_until do |invoices|
      next unless payable_until_before.present? || payable_until_after.present?

      invoices.where(Invoice.arel_table[:payable_until].between(payable_until_after..payable_until_before))
    end

    filter :statuses do |invoices|
      invoices.where(status: statuses) if statuses.present?
    end

    filter :ref do |invoices|
      invoices.where(Invoice.arel_table[:ref].matches("#{ref}%")) if ref.present?
    end

    filter :invoice_types do |invoices|
      invoice_types = Array.wrap(self.invoice_types).compact_blank
      invoices.where(type: invoice_types) if invoice_types.present?
    end
  end
end
