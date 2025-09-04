# frozen_string_literal: true

class MigrateInvoicePartDigests < ActiveRecord::Migration[8.0]
  def up
    DataDigestTemplate.where(type: 'DataDigestTemplates::InvoicePart')
                      .update_all(type: 'DataDigestTemplates::InvoiceItem') # rubocop:disable Rails/SkipsModelValidations
  end
end
