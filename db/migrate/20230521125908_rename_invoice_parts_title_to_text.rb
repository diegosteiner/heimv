class RenameInvoicePartsTitleToText < ActiveRecord::Migration[7.0]
  def up
    InvoicePart.where(type: 'InvoiceParts::Title').update_all(type: 'InvoiceParts::Text')
  end

  def down
    InvoicePart.where(type: 'InvoiceParts::Text').update_all(type: 'InvoiceParts::Title')
  end
end
