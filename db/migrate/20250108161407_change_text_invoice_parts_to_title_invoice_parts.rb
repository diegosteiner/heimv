class ChangeTextInvoicePartsToTitleInvoiceParts < ActiveRecord::Migration[8.0]
  def up
    InvoicePart.where(type: 'InvoiceParts::Text').update_all(type: 'InvoiceParts::Title')
  end
end
