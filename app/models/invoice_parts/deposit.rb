# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_parts
#
#  id                        :bigint           not null, primary key
#  accounting_account_nr     :string
#  accounting_cost_center_nr :string
#  amount                    :decimal(, )
#  breakdown                 :string
#  label                     :string
#  ordinal                   :integer
#  type                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  invoice_id                :bigint
#  usage_id                  :bigint
#  vat_category_id           :bigint
#
# Indexes
#
#  index_invoice_parts_on_invoice_id       (invoice_id)
#  index_invoice_parts_on_usage_id         (usage_id)
#  index_invoice_parts_on_vat_category_id  (vat_category_id)
#
# Foreign Keys
#
#  fk_rails_...  (invoice_id => invoices.id)
#  fk_rails_...  (usage_id => usages.id)
#  fk_rails_...  (vat_category_id => vat_categories.id)
#

module InvoiceParts
  class Deposit < Add
    InvoicePart.register_subtype self

    attr_accessor :reassign_payments

    after_save :reassign_payments!

    attribute :accounting_account_nr
    attribute :vat_category_id

    def reassign_payments!(payments = reassign_payments)
      return unless valid? && apply

      payments&.each { |payment| payment&.update!(invoice:) }
    end
  end
end
