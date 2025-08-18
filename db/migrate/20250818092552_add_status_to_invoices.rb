# frozen_string_literal: true

class AddStatusToInvoices < ActiveRecord::Migration[8.0]
  def change
    add_column :invoices, :status, :integer
    rename_column :invoices, :amount_open, :balance

    reversible do |direction|
      direction.up do
        DataDigestTemplates::Invoice.find_each do |ddt|
          prefilter_paid = ddt.prefilter_params['paid']
          ddt.prefilter_params['statuses'] = case prefilter_paid
                                             when 'false' then :outstanding
                                             when 'true' then :paid
                                             end
          ddt.save!
        end
      end
    end
  end
end
