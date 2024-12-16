# frozen_string_literal: true

class AccountingSettings < Settings
  attribute :tenant_debitor_account_nr_base, :integer, default: -> { 0 }
  attribute :debitor_account_nr, :string, default: -> { 1050 }
  attribute :rental_yield_account_nr, :string, default: -> { 6000 }
  attribute :rental_yield_vat_category_id, :integer
  attribute :currency_account_nr, :string
  attribute :vat_account_nr, :string, default: -> { 2016 }
  attribute :default_payment_account_nr, :string, default: -> { 2512 }
end
