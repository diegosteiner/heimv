# frozen_string_literal: true

class DropInvoicePartsTable < ActiveRecord::Migration[8.0]
  def up
    drop_table :invoice_parts
  end
end
