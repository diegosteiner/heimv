class RemoveInvoiceRefStrategyFromOrganisations < ActiveRecord::Migration[7.1]
  def change
    remove_column :organisations, :invoice_ref_strategy_type, :string
    add_column :organisations, :country_code, :string, default: 'CH', null: false
    rename_column :organisations, :ref_template, :booking_ref_template
    change_column_default :organisations, :booking_ref_template, from: '', to: ''
    change_column_default :organisations, :invoice_ref_template, from: '', to: ''

    reversible do |direction|
      direction.up do
        Organisation.find_each do |organisation|
          organisation.instance_exec do
            self.update!(currency: 'CHF', country_code: 'CH')
          end
        end
      end
    end
  end
end
