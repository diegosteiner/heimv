# frozen_string_literal: true

class AccountingSettings
  include StoreModel::Model

  attribute :enabled, :boolean, default: false
  attribute :debitor_account_nr, :string
  attribute :rental_yield_account_nr, :string
  attribute :rental_yield_vat_category_id
  attribute :vat_account_nr, :string
  attribute :payment_account_nr
  attribute :payment_account_nr
  attribute :liable_for_vat, :boolean, default: false
end
