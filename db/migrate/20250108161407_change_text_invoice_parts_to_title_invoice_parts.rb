# frozen_string_literal: true

class ChangeTextInvoicePartsToTitleInvoiceParts < ActiveRecord::Migration[8.0]
  def up
    InvoicePart.where(type: 'InvoiceParts::Text').update_all(type: 'InvoiceParts::Title') # rubocop:disable Rails/SkipsModelValidations
  end
end
