# frozen_string_literal: true

class AccountingSettings < Settings
  attribute :tenant_debitor_account_nr_base, :integer, default: -> { 0 }
  attribute :debitor_account_nr, :string
  attribute :currency_account_nr, :string
end
