# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_parts
#
#  id                        :integer          not null, primary key
#  invoice_id                :integer
#  usage_id                  :integer
#  type                      :string
#  amount                    :decimal(, )
#  label                     :string
#  breakdown                 :string
#  ordinal                   :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  vat_category_id           :integer
#  accounting_account_nr     :string
#  accounting_cost_center_nr :string
#
# Indexes
#
#  index_invoice_parts_on_invoice_id       (invoice_id)
#  index_invoice_parts_on_usage_id         (usage_id)
#  index_invoice_parts_on_vat_category_id  (vat_category_id)
#

module InvoiceParts
  class Deposit < Add
    InvoicePart.register_subtype self

    attr_accessor :unassigned_payments

    after_save :assign_payments

    attribute :vat_category_id, default: lambda { |invoice_part|
      invoice_part.organisation&.accounting_settings&.rental_yield_vat_category_id
    }
    attribute :accounting_account_nr, default: -> { organisation&.accounting_settings&.rental_yield_account_nr }

    def assign_payments
      return unless valid? && apply

      unassigned_payments&.each do |payment|
        payment&.update(invoice:)
      end
    end
  end
end
